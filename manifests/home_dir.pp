define accounts::home_dir(
  $user,
  $uid,
  $gid,
) {
  $owner = $uid ? { /^\d+/ => $uid, default => $user }
  $group = $gid ? { /^\d+$/ => $gid, /^[a-z0-9]+/ => $gid, default => $user }
  File { owner => $owner, group => $group, default => $user }, mode => '0644' }

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
    owner          => $owner,
    group          => $group,
  }

  concat::fragment { "${name}_header_ssh_config":
    target  => "${name}/.ssh/config",
    content => "# Managed with puppet\n",
    order   => '01',
  }
}

