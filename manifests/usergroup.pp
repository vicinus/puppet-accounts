# See README.md for details.
define accounts::usergroup (
  Enum['present', 'absent', 'ignore'] $ensure = 'present',
  Optional[Hash] $users = undef,
  Hash $global_users_defaults = {},
  Optional[Hash] $groups = undef,
  Optional[Boolean] $virtual_users = undef,
  Optional[Variant[String,Array[String]]] $realize_users = undef,
  Optional[Variant[String,Array[String],Hash[String,Variant[String,Array[String]]]]] $realize_sudoers = undef,
) {
  if $ensure != 'ignore' {
    if $virtual_users == undef {
      include ::accounts
      $_virtual_users = $accounts::virtual_users
    } else {
      $_virtual_users = $virtual_users
    }
    if $_virtual_users {
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
  
    if $users == undef {
      $_users = lookup({
        'name' => "accounts::usergroup::${name}",
        'value_type' => Hash,
        'merge' => {
          'strategy'        => 'deep',
          'knockout_prefix' => '-_-',
        },
        'default_value' => {},
      })
    } else {
      $_users = $users
    }
    create_resources($user_accounts_res, $_users, $users_defaults)
    if $groups == undef {
      $_groups = lookup({
        'name' => "accounts::usergroup::${name}::groups",
        'value_type' => Hash,
        'merge' => {
          'strategy'        => 'deep',
          'knockout_prefix' => '-_-',
        },
        'default_value' => {},
      })
    } else {
      $_groups = $groups
    }
    create_resources($group_res, $_groups)
 
    accounts::realize_sudoers($realize_sudoers)
    accounts::realize_users($realize_users)
  }
}
