open Alcotest

type test =
  { name : string
  ; input : Squeal.t
  ; expected : string
  }

let t ~name ~input ~expected = { name; input; expected }

let each tests f =
  List.iter (fun { name; input; expected } -> f name input expected) tests
;;

let test_select () =
  each
    [ t
        ~name:"simple query"
        ~input:Squeal.(create "SELECT * FROM users" ~params:[])
        ~expected:"SELECT * FROM users"
    ; t
        ~name:"query with params"
        ~input:
          Squeal.(create "SELECT * FROM users WHERE id = :id" ~params:[ ":id", int 1 ])
        ~expected:"SELECT * FROM users WHERE id = 1"
    ; t
        ~name:"query with multiple params"
        ~input:
          Squeal.(
            create
              "SELECT * FROM users WHERE id = :id AND name = :name"
              ~params:[ ":id", int 1; ":name", string "Alice" ])
        ~expected:"SELECT * FROM users WHERE id = 1 AND name = 'Alice'"
    ; t
        ~name:"query with multiple params in different order"
        ~input:
          Squeal.(
            create
              "SELECT * FROM users WHERE name = :name AND id = :id"
              ~params:[ ":id", int 1; ":name", string "Alice" ])
        ~expected:"SELECT * FROM users WHERE name = 'Alice' AND id = 1"
    ; t
        ~name:"query with join"
        ~input:
          Squeal.(
            create
              "SELECT * FROM users INNER JOIN posts ON users.id = posts.user_id"
              ~params:[])
        ~expected:"SELECT * FROM users INNER JOIN posts ON users.id = posts.user_id"
    ]
    (fun name input expected -> check string name expected (Squeal.to_string input))
;;

let test_insert () =
  each
    [ t
        ~name:"simple query"
        ~input:Squeal.(create "INSERT INTO users (name) VALUES ('Alice')" ~params:[])
        ~expected:"INSERT INTO users (name) VALUES ('Alice')"
    ; t
        ~name:"query with params"
        ~input:
          Squeal.(
            create
              "INSERT INTO users (name) VALUES (:name)"
              ~params:[ ":name", string "Alice" ])
        ~expected:"INSERT INTO users (name) VALUES ('Alice')"
    ; t
        ~name:"query with multiple params"
        ~input:
          Squeal.(
            create
              "INSERT INTO users (name, age) VALUES (:name, :age)"
              ~params:[ ":name", string "Alice"; ":age", int 30 ])
        ~expected:"INSERT INTO users (name, age) VALUES ('Alice', 30)"
    ]
    (fun name input expected -> check string name expected (Squeal.to_string input))
;;

let test_update () =
  each
    [ t
        ~name:"simple query"
        ~input:Squeal.(create "UPDATE users SET name = 'Alice'" ~params:[])
        ~expected:"UPDATE users SET name = 'Alice'"
    ; t
        ~name:"query with params"
        ~input:
          Squeal.(
            create "UPDATE users SET name = :name" ~params:[ ":name", string "Alice" ])
        ~expected:"UPDATE users SET name = 'Alice'"
    ; t
        ~name:"query with multiple params"
        ~input:
          Squeal.(
            create
              "UPDATE users SET name = :name, age = :age"
              ~params:[ ":name", string "Alice"; ":age", int 30 ])
        ~expected:"UPDATE users SET name = 'Alice', age = 30"
    ]
    (fun name input expected -> check string name expected (Squeal.to_string input))
;;

let () =
  let open Alcotest in
  run
    "Squeal Tests"
    [ "select", [ test_case "test select" `Quick test_select ]
    ; "insert", [ test_case "test insert" `Quick test_insert ]
    ; "update", [ test_case "test update" `Quick test_update ]
    ]
;;
