define accounts::realize_sudoers (
) {
  Accounts::Sudoers <| tag == $name |>
}
