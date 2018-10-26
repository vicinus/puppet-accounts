# Class: accounts:  See README.md for documentation.
class accounts (
  Boolean $manage_sudo = true,
  Boolean $manage_groups = true,
  Boolean $manage_users = true,
  Boolean $manage_ssh_config = true,
  Hash $managed_groups = {},
  Hash $managed_users = {},
  Hash $managed_users_defaults = {},
  Hash $managed_users_global_defaults = {},
  Optional[Variant[Hash[String,Any],Array[String]]] $managed_usergroups = undef,
  Boolean $virtual_users = false,
  Optional[Variant[String,Array[String]]] $realize_users = undef,
  Optional[Variant[String,Array[String],Hash[String,Variant[String,Array[String]]]]] $realize_sudoers = undef,
  String $ssh_match_resource_name = 'ssh::match',
) {
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
      if $managed_usergroups =~ Array[String] {
        $_managed_usergroups = make_hash($managed_usergroups, {
              'hiera_key' => 'accounts::usergroup::%k::config',
            })
      } elsif $managed_usergroups =~ Hash[String,Any] {
        $_managed_usergroups = $managed_usergroups
      } else {
        fail("accounts::managed_usergroups must either be an array or a hash, not: ${managed_usergroups}")
      }
      create_resources('accounts::usergroup', $_managed_usergroups, {
        global_users_defaults => $managed_users_global_defaults,
      })
    }
  }

  accounts::realize_sudoers($realize_sudoers)
  accounts::realize_users($realize_users)
}
