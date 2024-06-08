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
  ; params : Value.t list
  }

let int x = Value.Int x
let float x = Value.Float x
let bool x = Value.Bool x
let string x = Value.String x

let create query params = { query; params }

let to_string { query; params } =
  (* Replace all $1 with the first parameter, $2 with the second, etc. *)
  let query =
    List.fold_left
      (fun query (i, value) ->
        Str.global_replace
          (Str.regexp ("\\$" ^ string_of_int i))
          (Value.to_string value)
          query)
      query
      (List.mapi (fun i value -> i + 1, value) params)
  in

  query
;;

module Postgres = struct
  type connection = Postgresql.connection
  type error = Postgresql.error

  let connect ?host ?port ?database ?user ?password () =
    try
      Ok
        (new Postgresql.connection
           ~host:(Option.value host ~default:"")
           ~port:(Option.value port ~default:"")
           ~dbname:(Option.value database ~default:"")
           ~user:(Option.value user ~default:"")
           ~password:(Option.value password ~default:"")
           ())
    with
    | Postgresql.Error e ->
      print_endline (Postgresql.string_of_error e);
      Error e
  ;;

  let connect_with_uri uri =
    try Ok (new Postgresql.connection ~conninfo:uri ()) with
    | Postgresql.Error e ->
      print_endline (Postgresql.string_of_error e);
      Error e
  ;;

  let close connection = Ok connection#finish

  let exec sql (connection : Postgresql.connection) =
    match sql.params with
    | [] ->
      (* No parameters, just execute the query *)
      let query = to_string sql in

      (try Ok (connection#exec query) with
       | Postgresql.Error e ->
         print_endline (Postgresql.string_of_error e);
         Error e)
    | _ ->
      let params = sql.params |> List.map Value.to_string |> Array.of_list in

      (try Ok (connection#exec sql.query ~params) with
       | Postgresql.Error e ->
         print_endline (Postgresql.string_of_error e);
         Error e)
  ;;
end

type connection = Postgres.connection
type database_error = Postgres.error

let connect_with_uri uri = Postgres.connect_with_uri uri

let connect ?host ?port ?database ?user ?password () =
  Postgres.connect ?host ?port ?database ?user ?password ()
;;

let close = Postgres.close

let query q params connection =
  let sql = create q params in
  Lwt.return
    (match Postgres.exec sql connection with
     | Ok result -> Ok result#get_all_lst
     | Error e -> Error e)
;;

let query_one q params connection =
  query q params connection
  |> Lwt.map (fun result ->
    Result.bind result (function
      | [ row ] | row :: _ -> Ok (Some row)
      | [] -> Ok None))
;;
