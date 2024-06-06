```
(*
   1. Sql.(prepare "select * from users where id = :id" ~params:[ ":id", string id ])
   2. Sql.(prepare
      {|
        select user.name, article.title from users
        join articles on user.id = article.user_id
        where article.id = :id
      |}
      ~params:[ ":id", string id ])
  3. Sql.(prepare
      "insert into articles (title, content) values (:title, :content)"
      ~params:[ ":title", string title; ":content", string content ])
*)
```

```ocaml
module Database = Squeal.Database.Make(Postgres)

let result = Database.exec
        Squeal.(prepare "select * from users where id = :id" ~params:[ ":id", string id ])
    in
```

```
let _ = Squeal.(prepare "select * from users" ~params:[])

let _ = Squeal.(prepare "select * from users where id = :id" ~params:[ ":id", int 1 ])

let _ =
  Squeal.(
    prepare
      "select * from users where id = :id and name = :name"
      ~params:[ ":id", int 1; ":name", string "foo" ])
;;

let _ =
  Squeal.(
    prepare
      "insert into users (name, age) values (:name, :age)"
      ~params:[ ":name", string "foo"; ":age", int 1 ])
;;

let _ =
  Squeal.(
    prepare
      "update users set name = :name, age = :age where id = :id"
      ~params:[ ":name", string "foo"; ":age", int 1; ":id", int 1 ])
;;
```

```ocaml
Squeal.create "select * from users where id = :id"
|> Squeal.bind ":id" Squeal.int
|> Squeal.exec

(* or *)

Squeal.(
    create "select * from users where id = :id"
    |> bind ":id" int
    |> exec
)


(* let query = Squeal.( *)
(*   select [ *)
(*     field "name"; *)
(*     field "age"; *)
(*   ] ( *)
(*     from "users" ( *)
(*       where (field "age" >. int 18) *)
(*     ) *)
(*   ) *)
(* ) in *)
```
