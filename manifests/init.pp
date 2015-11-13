class accounts (
  $manage_sudo = true,
  $manage_groups   = true,
  $manage_users    = true,
  $manage_ssh_config = true,
  $managed_groups = undef,
  $managed_users = undef,
  $managed_users_defaults = undef,
  $managed_users_global_defaults = undef,
  $managed_usergroups = undef,
  $virtual_users = false,
  $realize_users = undef,
  $realize_sudoers = undef,
  $sudo_tag_splitter = ' - ',
) {
  validate_bool($manage_groups)
  validate_bool($manage_users)

  if $manage_sudo {
    include ::accounts::sudo
  }

  if $manage_groups {
    if $managed_groups {
      $real_managed_groups = hiera_hash('accounts::managed_groups',
          $managed_groups)
      create_resources('accounts::group', $real_managed_groups)
    }
  }

  if $manage_users {
    if $managed_users_global_defaults {
      $real_managed_users_global_defaults = hiera_hash(
          'accounts::managed_users_global_defaults',
          $managed_users_global_defaults)
    }
    if $managed_users {
      $real_managed_users = hiera_hash('accounts::managed_users',
          $managed_users)
      if $managed_users_defaults {
        $real_managed_users_defaults = hiera_hash(
            'accounts::managed_users_defaults',
            $managed_users_defaults)
      }
      create_resources('accounts::user', $real_managed_users,
        accounts_deepmerge(
          $real_managed_users_global_defaults,
          $real_managed_users_defaults
        )
      )
    }
    if $managed_usergroups {
      if is_array($managed_usergroups) {
        $real_managed_usergroups = make_hashx(
            hiera_array('accounts::managed_usergroups', $managed_usergroups))
      } elsif is_hash($managed_usergroups) {
        $real_managed_usergroups = hiera_hash('accounts::managed_usergroups',
            $managed_usergroups)
      } else {
        fail("accounts::managed_usergroups must either be an array or a hash, not: ${managed_usergroups}")
      }
      create_resources('accounts::usergroup', $real_managed_usergroups, {
        global_users_defaults => $managed_users_global_defaults,
      })
    }
  }

  if $realize_users {
    accounts::realize_users { $realize_users: }
  }
  if $realize_sudoers {
    if is_hash($realize_sudoers) {
      $real_realize_sudoers = join_keys_to_values($realize_sudoers, $::account::sudo_tag_splitter)
    } else {
      $real_realize_sudoers = $realize_sudoers
    }
    accounts::realize_sudoers { $real_realize_sudoers: }
  }
}
