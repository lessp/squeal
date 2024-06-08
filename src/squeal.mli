module Value : sig
  type t =
    | Bool of bool
    | Float of float
    | Int of int
    | String of string

  val to_string : t -> string
end

type t

(** Create a value from an integer. *)
val int : int -> Value.t

(** Create a value from a float. *)
val float : float -> Value.t

(** Create a value from a string. *)
val string : string -> Value.t

(** Create a value from a boolean. *)
val bool : bool -> Value.t

(** [create query ~params] prepares a query for execution.

    {[
      let query =
        Squeal.(create "select * from users where id = :id" ~params:[ ":id", string id ])
      in

      Database.exec query
    ]} *)
val create : string -> Value.t list -> t

(** [to_string query] returns the SQL query as a string.

    {[
      Squeal.(
        to_string
        @@ prepare "select * from users where id = :id" ~params:[ ":id", int id ])

      (* would yield "select * from users where id = 123" *)
    ]} *)
val to_string : t -> string

type connection
type database_error

val connect
  :  ?host:string
  -> ?port:string
  -> ?database:string
  -> ?user:string
  -> ?password:string
  -> unit
  -> (connection, database_error) result

val connect_with_uri : string -> (connection, database_error) result

val close : connection -> (unit, database_error) result

val query
  :  string
  -> Value.t list
  -> connection
  -> (string list list, database_error) result Lwt.t

val query_one
  :  string
  -> Value.t list
  -> connection
  -> (string list option, database_error) result Lwt.t
