class accounts (
  $manage_groups   = true,
  $manage_users    = true,
  $managed_groups = {},
  $managed_users = {},
  $managed_users_defaults = {},
  $managed_usergroups = {},
  $manage_sudoers  = false,
  $sudo_class = 'sudo',
  $sudo_resource = 'sudo::sudoers',
) {
  validate_bool($manage_groups)
  validate_bool($manage_users)
  validate_bool($manage_sudoers)

  if ($manage_groups) {
    create_resources('group', $managed_groups)
  }

  if ($manage_users) {
    if is_array($managed_users) {
      $real_managed_users = merge($managed_users)
    } else {
      $real_managed_users = $managed_users
    }
    create_resources('accounts::user', $real_managed_users, $managed_users_defaults)
    if !empty($managed_usergroups) {
      if is_array($managed_usergroups) {
        accounts::usergroup { $managed_usergroups: }
      } else {
        create_resources('accounts::usergroup', $managed_usergroups)
      }
    }
  }


  if ($manage_sudoers) {
    include $sudo_class
  }
}
