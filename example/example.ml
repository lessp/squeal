let () =
  (* let _query = *)
  (*   Squeal.(create "select * from users where id = :id" ~params:[] |> bind ":id" (int 1)) *)
  (* in *)

  (* Db.run () *)
  let connection =
    Squeal.Postgres.connect
      ~host:"aws-0-eu-central-1.pooler.supabase.com"
      ~port:6543
      ~database:"postgres"
      ~user:"postgres.qxtisvutbpzztrccgziy"
      ~password:"cZ5t(d2_3@Jhvtf"
      ()
    |> Result.get_ok
  in

  let query = Squeal.(create "select * from articles" ~params:[]) in

  let result = Squeal.Postgres.exec connection query |> Result.get_ok in

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
    | _ -> ())
;;
