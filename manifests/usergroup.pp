# See README.md for details.
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
      lookup({
        'name' => "accounts::usergroup::${name}::defaults",
        'value_type' => Hash,
        'merge' => {
          'strategy'        => 'deep',
          'knockout_prefix' => '-_-',
        },
        'default_value' => {},
      }))
  if $users {
    create_resources($user_accounts_res, $users, $users_defaults)
  } else {
    create_resources($user_accounts_res, lookup({
        'name' => "accounts::usergroup::${name}",
        'value_type' => Hash,
        'merge' => {
          'strategy'        => 'deep',
          'knockout_prefix' => '-_-',
        },
        'default_value' => {},
      }), $users_defaults)
  }
  if $groups {
    create_resources($group_res, $groups)
  } else {
    create_resources($group_res, lookup({
        'name' => "accounts::usergroup::${name}::groups",
        'value_type' => Hash,
        'merge' => {
          'strategy'        => 'deep',
          'knockout_prefix' => '-_-',
        },
        'default_value' => {},
      }))
  }
  if $realize_users {
    accounts::realize_users { $realize_users: }
  }
  if $realize_sudoers {
    if is_hash($realize_sudoers) {
      include ::accounts
      $real_realize_sudoers = join_keys_to_values($realize_sudoers, $::accounts::sudo_tag_splitter)
    } else {
      $real_realize_sudoers = $realize_sudoers
    }
    accounts::realize_sudoers { $real_realize_sudoers: }
  }
}
