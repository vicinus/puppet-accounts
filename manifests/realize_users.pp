# See README.md for details.
define accounts::realize_users {
  Accounts::User <| tag == $name |>
}
