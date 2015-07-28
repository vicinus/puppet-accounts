define accounts::usergroup (
  $users = undef,
  $global_users_defaults = {},
  $groups = undef,
) {
  $users_defaults = accounts_deepmerge($global_users_defaults,
      hiera_hash("accounts::usergroup::${name}::defaults", {}))
  if $users {
    create_resources('accounts::user', $users, $users_defaults)
  } else {
    create_resources('accounts::user',
        hiera_hash("accounts::usergroup::${name}", {}), $users_defaults)
  }
  if $groups {
    create_resources('group', $groups)
  } else {
    create_resources('group',
        hiera_hash("accounts::usergroup::${name}::groups", {}))
  }
}
