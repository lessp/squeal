open Lwt.Syntax

let get_users db =
  let* rows = Squeal.(query "select * from users" [] db) in

  match rows with
  | Ok rows ->
    let users =
      rows
      |> List.map (function
        | [ id; title ] -> Some (id, title)
        | _ -> None)
      |> List.filter_map Fun.id
    in
    Lwt.return users
  | Error _ -> Lwt.return []
;;

let get_user db id =
  let* row = Squeal.(query_one "select * from users where id = $1" [ int id ] db) in

  match row with
  | Ok (Some [ id; title ]) -> Lwt.return (Ok (id, title))
  | Ok _ -> Lwt.return (Error "Invalid row")
  | Error _ -> Lwt.return (Error "User not found")
;;

let () =
  let db = Squeal.connect_with_uri "postgresql://" |> Result.get_ok in

  let _users = get_users db in
  let _user = get_user db 1 in

  ()
;;
