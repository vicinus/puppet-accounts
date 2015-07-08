define accounts::usergroup (
  $users = undef,
  $users_defaults = {},
  $groups = undef,
) {
  if $users {
    create_resources('accounts::user', $users, $users_defaults)
  } else {
    create_resources('accounts::user', hiera_hash("accounts::usergroup::$name", {}), hiera_hash("accounts::usergroup::${name}::defaults", $users_defaults))
  }
  if $groups {
    create_resources('group', $groups)
  } else {
    create_resources('group', hiera_hash("accounts::usergroup::${name}::groups", {}))
  }
}
