define accounts::usergroup (
  $users = undef,
  $global_users_defaults = {},
  $groups = undef,
) {
  include ::accounts
  if $accounts::virtual_users {
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
}
