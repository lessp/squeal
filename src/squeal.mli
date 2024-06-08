module Value : sig
  type t =
    | Bool of bool
    | Float of float
    | Int of int
    | String of string

  val to_string : t -> string
end

type t

val int : int -> Value.t
val float : float -> Value.t
val string : string -> Value.t
val bool : bool -> Value.t

val create : string -> Value.t list -> t

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
