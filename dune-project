(lang dune 3.15)

(name squeal)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name squeal)
 (synopsis "A short synopsis")
 (description "A longer description")
 (allow_empty)
 (depends ocaml dune ppx_expect)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
