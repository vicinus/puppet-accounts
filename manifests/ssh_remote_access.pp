define accounts::ssh_remote_access (
  $user = undef,
  $group = undef,
  $homedir = undef,
  $key = undef,
  $remote_host = undef,
  $remote_user = undef,
  $no_host_key_verification = true,
  $ssh_key_filename = undef,
) {
  if $homedir {
    $sshdir = "$homedir/.ssh"
  } else {
    $sshdir = "/home/$user/.ssh"
  }
  if $ssh_key_filename {
    $real_ssh_key_filename = $ssh_key_filename
  } else {
    $real_ssh_key_filename = "$name.key"
  }
  file { "$sshdir/$real_ssh_key_filename":
    owner => $user,
    group => $group,
    mode => '0600',
    content => "$key\n",
  }
  if $remote_host {
    $ssh_config_content = join([
        "Host $remote_host\n  IdentityFile $sshdir/$real_ssh_key_filename\n",
        ($remote_user ? { default => "  User $remote_user\n", undef => ""}),
        ($no_host_key_verification ? { true => "  CheckHostIP no\n  StrictHostKeyChecking no\n", default =>  ""}),
      ], "")
    
    concat::fragment { "ssh_remote_access_$name":
      target => "$sshdir/config",
      content => $ssh_config_content,
      order => '10',
    }
  }
}
