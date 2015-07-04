class accounts (
  $manage_groups   = true,
  $manage_users    = true,
  $managed_users = {},
  $managed_users_defaults = {},
  $manage_sudoers  = false,
  $sudo_class = 'sudo',
  $sudo_resource = 'sudo::sudoers',
) {
  validate_bool($manage_groups)
  validate_bool($manage_users)
  validate_bool($manage_sudoers)

  if ($manage_groups) {
  }

  if ($manage_users) {
    create_resources('accounts::user', $managed_users, $managed_users_defaults)
  }

  if ($manage_sudoers) {
    include $sudo_class
  }
}
