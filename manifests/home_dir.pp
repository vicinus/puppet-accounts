define accounts::home_dir(
  $user,
  $uid,
  $gid,
) {
  File { owner => $uid ? { /^\d+/ => $uid, default => $user }, group => $gid ? { /^\d+/ => $gid, default => $user }, mode => '0644' }

  file { [$name, "${name}/.ssh", "${name}/.vim"]:
    ensure => directory,
    mode => '0700',
  }

  file { "${name}/.ssh/authorized_keys":
   ensure => file,
   mode   => '0600',
  }
}

