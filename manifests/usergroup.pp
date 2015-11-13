define accounts::usergroup (
  $users = undef,
  $global_users_defaults = {},
  $groups = undef,
  $virtual_users = undef,
  $realize_users = undef,
  $realize_sudoers = undef,
) {
  if $virtual_users == undef {
    include ::accounts
    $real_virtual_users = $accounts::virtual_users
  } else {
    $real_virtual_users = $virtual_users
  }
  if $real_virtual_users {
    $user_accounts_res = '@accounts::user'
  } else {
    $user_accounts_res = 'accounts::user'
  }
  $group_res = 'accounts::group'
  $users_defaults = accounts_deepmerge($global_users_defaults,
      hiera_hash("accounts::usergroup::${name}::defaults", {}))
  if $users {
    create_resources($user_accounts_res, $users, $users_defaults)
  } else {
    create_resources($user_accounts_res,
        hiera_hash("accounts::usergroup::${name}", {}), $users_defaults)
  }
  if $groups {
    create_resources($group_res, $groups)
  } else {
    create_resources($group_res,
        hiera_hash("accounts::usergroup::${name}::groups", {}))
  }
  if $realize_users {
    accounts::realize_users { $realize_users: }
  }
  if $realize_sudoers {
    accounts::realize_sudoers { $realize_sudoers: }
  }
}
