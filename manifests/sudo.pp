class accounts::sudo (
  $keep_os_defaults = true,
  $manage_sudo_package = true,
  $sudo_package_name = 'sudo',
  $sudo_package_state = 'present',
  $sudoers_filename = '/etc/sudoers',
  $sudo_global_defaults = {},
  $sudo_global_includes = [],
  $sudo_global_include_dirs = [],
  $sudo_global_config = [],
  $sudoersd = '/etc/sudoers.d',
  $manage_sudoersd = true,
) {

  if $manage_sudo_package {
    package { $sudo_package_name:
      ensure => $sudo_package_state,
    }
  }

  if empty($sudo_global_include_dirs) {
    if $sudoersd {
      $real_sudo_global_include_dirs = [ $sudoersd, ]
    }
  } else {
    $real_sudo_global_include_dirs = $sudo_global_include_dirs
  }

  if $sudoersd {
    file { $sudoersd:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      purge   => $manage_sudoersd,
      recurse => $manage_sudoersd,
      force   => $manage_sudoersd,
    }
  }

  if ! $keep_os_defaults {

    if empty($sudo_global_config) {
      file { $sudoers_filename:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => template('accounts/sudo.erb'),
      }
    } else {
      concat { $sudoers_filename:
        ensure         => present,
        ensure_newline => true,
        force          => true,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
      }
      concat::fragment { "${sudoers_filename}_header":
        target => $sudoers_filename,
        content => template('accounts/sudo.erb'),
        order => '001',
      }
      create_resources('accounts::sudoers',
        make_hash($sudo_global_config, "accounts_sudo"), { 
          sudoers_fragment => $sudoers_filename,
          order => '010',
        }
      )
    }
  }
}
