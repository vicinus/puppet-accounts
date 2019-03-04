# See README.md for details.
define accounts::home_dir (
  String $user,
  Boolean $sftponly = false,
  Hash $ssh_known_hosts = {},
  Boolean $manage_ssh_config = false,
  Boolean $manage_home_dir = true,
  Optional[String] $mode_home_directory = undef,
  Boolean $purge_home_directory = false,
  Boolean $purge_ssh_directory = false,
  Optional[Stdlib::Filemode] $default_mode = undef,
  Optional[String] $group = undef,
  Boolean $create_authorized_keys = true,
) {
  File { owner => $user, group => $group, mode => $default_mode, }

  if $manage_home_dir {
    file { $name:
      ensure  => directory,
      owner   => ($sftponly ? { true => 'root', false => undef }),
      group   => ($sftponly ? { true => 'root', false => undef }),
      mode    => $mode_home_directory,
      purge   => $purge_home_directory,
      force   => $purge_home_directory,
      recurse => $purge_home_directory,
    }
  }

  file { "${name}/.ssh":
    ensure  => directory,
    mode    => '0700',
    purge   => $purge_ssh_directory,
    force   => $purge_ssh_directory,
    recurse => $purge_ssh_directory,
  }

  file { "${name}/.ssh/known_hosts":
    *  => $ssh_known_hosts,
  }

  if $create_authorized_keys {
    file { "${name}/.ssh/authorized_keys":
      ensure => file,
      mode   => '0600',
    }
  }

  if $manage_ssh_config {
    concat { "${name}/.ssh/config":
      ensure         => present,
      ensure_newline => true,
      owner          => $user,
      group          => $group,
      require        => File["${name}/.ssh"],
    }

    concat::fragment { "${user}_header_ssh_config":
      target  => "${name}/.ssh/config",
      content => "# Managed with puppet\n",
      order   => '01',
    }
  }
}
