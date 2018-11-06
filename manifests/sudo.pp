# Class: accounts::sudo:  See README.md for documentation.
class accounts::sudo (
  Boolean $keep_os_defaults = true,
  Boolean $manage_sudo_package = true,
  String $sudo_package_name = 'sudo',
  String $sudo_package_state = 'present',
  Stdlib::Unixpath $sudoers_filename = '/etc/sudoers',
  Hash $sudo_global_defaults = {},
  Array $sudo_global_includes = [],
  Array $sudo_global_include_dirs = [],
  Array $sudo_global_config = [],
  Stdlib::Unixpath $sudoersd = '/etc/sudoers.d',
  Boolean $manage_sudoersd = true,
  Hash $sudoers = {},
  Boolean $default_env_file = false,
  Stdlib::Unixpath $default_env_filename = '/etc/env-sudo',
  Optional[Hash[String,String]] $default_env_file_content = undef,
) {

  if $manage_sudo_package {
    package { $sudo_package_name:
      ensure => $sudo_package_state,
    }
  }

  if empty($sudo_global_include_dirs) {
    if $sudoersd {
      $_sudo_global_include_dirs = [ $sudoersd, ]
    }
  } else {
    $_sudo_global_include_dirs = $sudo_global_include_dirs
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
        owner          => 'root',
        group          => 'root',
        mode           => '0440',
      }
      concat::fragment { "${sudoers_filename}_header":
        target  => $sudoers_filename,
        content => template('accounts/sudo.erb'),
        order   => '001',
      }
      create_resources('accounts::sudoers',
        make_hash($sudo_global_config, 'accounts_sudo'), {
          sudoers_fragment => $sudoers_filename,
          order => '010',
        }
      )
    }
  }
  if !empty($sudoers) {
    create_resources('accounts::sudoers', $sudoers)
  }

  if $default_env_file {
    concat { $default_env_filename:
      ensure         => present,
      ensure_newline => true,
      owner          => 'root',
      group          => 'root',
      mode           => '0440',
    }
    concat::fragment { "${default_env_filename}_header":
      target  => $default_env_filename,
      content => "${join(suffix(join_keys_to_values($default_env_file_content,'=\''),'\''),"\n")}\n",
      order   => '001',
    }
  }
}
