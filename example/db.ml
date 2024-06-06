(* open Lwt.Syntax *)

let conn =
  PGOCaml.
    { host = `Hostname "aws-0-eu-central-1.pooler.supabase.com"
    ; port = 6543
    ; database = "postgres"
    ; user = "postgres.qxtisvutbpzztrccgziy"
    ; password = "cZ5t(d2_3@Jhvtf"
    }
;;

let run_query () =
  let connection =
    new Postgresql.connection
      ~host:"aws-0-eu-central-1.pooler.supabase.com"
      ~port:"6543"
      ~dbname:"postgres"
      ~user:"postgres.qxtisvutbpzztrccgziy"
      ~password:"cZ5t(d2_3@Jhvtf"
      ()
  in

  let result =
    connection#exec_prepared "SELECT * FROM articles where id = $1" ~params:[| "1" |]
  in

  result#get_all_lst
  |> List.iter (fun row ->
    match row with
    | [] -> ()
    | [ id; created_at; title; content ] ->
      Printf.printf
        "id: %s, created_at: %s, title: %s, content: %s\n"
        id
        created_at
        title
        content
    | _ -> ());

  connection#finish
;;

(* let run_query () = *)
(*   let dbh = PGOCaml.connect ~desc:conn () in *)
(*   Printf.printf "Connected to database\n"; *)

(*   (1* PGOCaml.begin_work dbh; *1) *)
(*   (1* Printf.printf "Connected to database\n"; *1) *)
(*   (1* let query = "INSERT INTO users (name) VALUES ('Alice')" in *1) *)
(*   (1* Printf.printf "Query: %s\n" query; *1) *)
(*   (1* let () = PGOCaml.prepare dbh ~name:"Myquery" ~query () in *1) *)
(*   (1* Printf.printf "Prepared query\n"; *1) *)
(*   (1* let rows = PGOCaml.execute dbh ~name:"Myquery" ~params:[] () in *1) *)
(*   (1* Printf.printf "Executed query\n"; *1) *)
(*   (1* PGOCaml.commit dbh; *1) *)
(*   (1* Printf.printf "Committed transaction\n"; *1) *)

(*   (1* let () = *1) *)
(*   (1*   List.iter *1) *)
(*   (1*     (fun row -> *1) *)
(*   (1*       match row with *1) *)
(*   (1*       | [ Some id; Some name ] -> Printf.printf "id: %s, name: %s\n" id name *1) *)
(*   (1*       | _ -> ()) *1) *)
(*   (1*     rows *1) *)
(*   (1* in *1) *)

(*   (1* let query = "SELECT id, name FROM users" in *1) *)
(*   (1* let* result = Connect.exec dbh ~query in *1) *)
(*   (1* let () = *1) *)
(*   (1*   List.iter *1) *)
(*   (1*     (fun row -> *1) *)
(*   (1*       match row with *1) *)
(*   (1*       | [ Some id; Some name ] -> Printf.printf "id: %s, name: %s\n" id name *1) *)
(*   (1*       | _ -> ()) *1) *)
(*   (1*     result *1) *)
(*   (1* in *1) *)
(*   PGOCaml.close dbh; *)

(*   Lwt.return () *)
(* ;; *)

(* let run () = Lwt_main.run (run_query ()) *)
let run () = run_query ()
