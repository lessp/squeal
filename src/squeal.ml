module Value = struct
  type t =
    | Bool of bool
    | Float of float
    | Int of int
    | String of string

  let to_string = function
    | Bool b -> Bool.to_string b
    | Float f -> Float.to_string f
    | Int i -> Int.to_string i
    | String s -> "\'" ^ String.escaped s ^ "\'"
  ;;
end

type t =
  { query : string
  ; params : (string * Value.t) list
  }

let int x = Value.Int x
let float x = Value.Float x
let bool x = Value.Bool x
let string x = Value.String x

let create query ~params = { query; params }

let bind name value t = { t with params = (name, value) :: t.params }

let to_string { query; params } =
  List.fold_left
    (fun query (name, value) ->
      (* Replace all occurrences of the parameter name with the value *)
      Str.global_replace (Str.regexp (Str.quote name)) (Value.to_string value) query)
    query
    params
;;

module Postgres = struct
  type connection = Postgresql.connection
  type error = Postgresql.error

  let connect ?host ?port ?user ?password ?database () =
    let host = Option.value host ~default:"localhost" in
    let port = Option.value port ~default:5432 |> Int.to_string in
    let user = Option.value user ~default:"postgres" in
    let password = Option.value password ~default:"" in
    let database = Option.value database ~default:"postgres" in

    try
      Ok (new Postgresql.connection ~host ~port ~user ~password ~dbname:database ())
    with
    | Postgresql.Error e -> Error e
  ;;

  let close connection = Ok connection#finish

  let exec (connection : Postgresql.connection) sql =
    match sql.params with
    | [] ->
      (* No parameters, just execute the query *)
      let query = to_string sql in

      (try Ok (connection#exec query) with
       | Postgresql.Error e -> Error e)
    | _ ->
      (* Parameters, prepare the query and bind them *)
      let params =
        sql.params
        |> List.map (fun (_name, value) -> Value.to_string value)
        |> Array.of_list
      in

      (try Ok (connection#exec_prepared sql.query ~params) with
       | Postgresql.Error e -> Error e)
  ;;
end

(* module type Database = sig *)
(*   type connection *)
(*   type error = string *)

(*   val connect : string -> (connection, error) result *)
(*   val close : connection -> (unit, error) result *)
(*   val exec : t -> ('ok, error) result *)
(* end *)

(* let exec (module Db : Database) (sql : t) = *)
(*   match Db.exec sql with *)
(*   | Ok _ -> Ok () *)
(*   | Error e -> Error e *)
(* ;; *)
