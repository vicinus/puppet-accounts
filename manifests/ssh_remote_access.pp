define accounts::ssh_remote_access (
  $ensure = 'present',
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
    $real_homedir = $homedir
  } else {
    $real_homedir = "/home/${user}"
  }
  $sshdir = "${real_homedir}/.ssh"
  if $ssh_key_filename {
    $real_ssh_key_filename = $ssh_key_filename
  } else {
    $real_ssh_key_filename = "${name}.key"
  }
  file { "${sshdir}/${real_ssh_key_filename}":
    ensure  => $ensure,
    owner   => $user,
    group   => $group,
    mode    => '0600',
    require => Accounts::Home_dir[$real_homedir],
    content => "${key}\n",
  }
  if $remote_host {
    $ssh_config_content = join([
        "Host ${remote_host}\n",
        "  IdentityFile ${sshdir}/${real_ssh_key_filename}\n",
        ($remote_user ? { default => "  User ${remote_user}\n", undef => ''}),
        ($no_host_key_verification ? {
          true => "  CheckHostIP no\n  StrictHostKeyChecking no\n",
          default =>  ''
        }),
      ], '')
    
    concat::fragment { "ssh_remote_access_${name}":
      ensure  => $ensure,
      target  => "${sshdir}/config",
      content => $ssh_config_content,
      order   => '10',
    }
  }
}
