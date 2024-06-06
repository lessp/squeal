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
val create : string -> params:(string * Value.t) list -> t

(** [bind query name value] binds a value to a named parameter in a query.

    {[
      let query =
        Squeal.(create "select * from users where id = :id")
        |> Squeal.(bind ":id" (int id))
      in

      Database.exec query
    ]}

    Or, bind multiple values to the same query.

    {[
      let query = Squeal.(create "select * from users where id = :id") in

      let query = Squeal.(bind query ":id" (int 1)) in
      Database.exec query;

      let query = Squeal.(bind query ":id" (int 2)) in
      Database.exec query
    ]} *)
val bind : string -> Value.t -> t -> t

(** [to_string query] returns the SQL query as a string.

    {[
      Squeal.(
        to_string
        @@ prepare "select * from users where id = :id" ~params:[ ":id", int id ])

      (* would yield "select * from users where id = 123" *)
    ]} *)
val to_string : t -> string

module Postgres : sig
  type connection
  type error

  val connect
    :  ?host:string
    -> ?port:int
    -> ?user:string
    -> ?password:string
    -> ?database:string
    -> unit
    -> (connection, error) result

  val close : connection -> (unit, error) result

  val exec : connection -> t -> (Postgresql.result, error) result
end

(*module type Database = sig *)
(*  type connection *)
(*  type error = string *)

(*  val connect : string -> (connection, error) result *)
(*  val close : connection -> (unit, error) result *)
(*  val exec : t -> ('ok, error) result *)
(*end *)

(*(1** [execute query] executes a prepared query. *)

(*    {[ *)
(*      Squeal.(execute query) *)
(*    ]} *1) *)
(*val exec : (module Database) -> t -> (unit, string) result *)

(*(1** [Make] is a functor that takes a database implementation and returns a module *)
(*    that provides a simple API for building and executing SQL queries. *)

(*    {[ *)
(*      module Postgres = struct *)
(*        type t = Postgres.t *)
(*        type error = Postgres.error *)

(*        let connect = Postgres.connect *)
(*        let close = Postgres.close *)
(*        let exec = Postgres.exec *)
(*      end *)

(*      module Squeal = Squeal.Make (Postgres) *)
(*    ]} *1) *)
(*module Make : functor (_ : Database) -> S *)
