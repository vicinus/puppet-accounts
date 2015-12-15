define accounts::home_dir (
  $user,
  $ssh_known_hosts = {},
  $manage_ssh_config = undef,
  $manage_home_dir = true,
  $purge_home_directory = false,
  $purge_ssh_directory = false,
  $default_mode = '0600',
  $group = undef,
  $create_authorized_keys = true,
) {
  File { owner => $user, group => $group, mode => $default_mode, }

  if $manage_home_dir {
    file { $name:
      ensure => directory,
      purge => $purge_home_directory,
      force => $purge_home_directory,
      recurse => $purge_home_directory,
    }
  }

  file { "${name}/.ssh":
    ensure => directory,
    mode   => '0700',
    purge => $purge_ssh_directory,
    force => $purge_ssh_directory,
    recurse => $purge_ssh_directory,
  }

  if is_hash($ssh_known_hosts) and $ssh_known_hosts['manage'] {
    file { "${name}/.ssh/known_hosts":
      ensure => file,
      replace => $ssh_known_hosts['replace'],
      content => $ssh_known_hosts['content'],
      source => $ssh_known_hosts['source'],
    }
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
      force          => true,
      owner          => $user,
      group          => $group,
    }

    concat::fragment { "${user}_header_ssh_config":
      target  => "${name}/.ssh/config",
      content => "# Managed with puppet\n",
      order   => '01',
    }
  }
}
