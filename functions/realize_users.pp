function accounts::realize_users (
  Optional[Variant[String,Array[String]]] $list,
) {
  if $list != undef {
    if $list =~ String {
      Accounts::User <| tag == $list |>
    } else {
      $list.each |$item| {
        Accounts::User <| tag == $item |>
      }
    }
  }
}
