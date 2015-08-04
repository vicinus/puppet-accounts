define accounts::home_dir(
  $user,
  $group = undef,
) {
  File { owner => $user, group => $group, mode => '0644', }

  file { [$name, "${name}/.ssh"]:
    ensure => directory,
    mode   => '0700',
  }

  file { "${name}/.ssh/authorized_keys":
    ensure => file,
    mode   => '0600',
  }

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

