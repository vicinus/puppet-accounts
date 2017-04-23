# Class: accounts:  See README.md for documentation.
class accounts (
  $manage_sudo = true,
  $manage_groups   = true,
  $manage_users    = true,
  $manage_ssh_config = true,
  $managed_groups = {},
  $managed_users = {},
  $managed_users_defaults = {},
  $managed_users_global_defaults = {},
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
    create_resources('accounts::group', $managed_groups)
  }

  if $manage_users {
    if $managed_users {
      create_resources('accounts::user', $managed_users,
        accounts_deepmerge(
          $managed_users_global_defaults,
          $managed_users_defaults
        )
      )
    }
    if $managed_usergroups {
      if is_array($managed_usergroups) {
        $_managed_usergroups = make_hash($managed_usergroups, {
              'hiera_key' => 'accounts::usergroup::%k::config',
            })
      } elsif is_hash($managed_usergroups) {
        $_managed_usergroups = $managed_usergroups
      } else {
        fail("accounts::managed_usergroups must either be an array or a hash, not: ${managed_usergroups}")
      }
      create_resources('accounts::usergroup', $_managed_usergroups, {
        global_users_defaults => $managed_users_global_defaults,
      })
    }
  }

  # order of realizing virtual resources first in, last out.
  # so order is important!!!
  if $realize_sudoers {
    if is_hash($realize_sudoers) {
      $real_realize_sudoers = join_keys_to_values($realize_sudoers, $::account::sudo_tag_splitter)
    } else {
      $real_realize_sudoers = $realize_sudoers
    }
    accounts::realize_sudoers { $real_realize_sudoers: }
  }
  if $realize_users {
    accounts::realize_users { $realize_users: }
  }
}
