define accounts::realize_sudoers {
  include ::accounts
  if $::accounts::sudo_tag_splitter in $name {
    $namesplit = split($name, $::accounts::sudo_tag_splitter)
    $usertag = $namesplit[0]
    $sudoerstag = $namesplit[1]
    Accounts::Sudoers <| tag == $usertag and tag == $sudoerstag |>
  } else {
    Accounts::Sudoers <| tag == $name |>
  }
}
