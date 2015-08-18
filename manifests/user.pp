define accounts::user(
  $ensure = 'present',
  $uid = undef,
  $gid = undef,
  $shell = '/bin/bash',
  $comment = undef,
  $home = "/home/${name}",
  $groups = [],
  $password = '!',
  $locked = false,
  $managehome = true,
  $managedefaultgroup = true,
  $ssh_keys = [],
  $ssh_keys_location = undef,
  $purge_ssh_keys = true,
  $files = [],
  $defaultfiles = [],
  $default_root_sudo = false,
  $sudoers = [],
  $ssh_remote_access = [],
) {
  validate_re($ensure, '^(present|absent)$')
  if $uid != undef {
    validate_re($uid, '^\d+$')
  }
  validate_re($shell, '^/')
  validate_string($comment)
  validate_re($home, '^/')
  validate_array($groups)
  if $password != undef {
    validate_string($password)
  }
  if $gid {
    if $gid =~ /^\d+$/ {
      $usergroupname = $name
    } else {
      $usergroupname = $gid
    }
  }

  if $locked {
    case $::operatingsystem {
      'debian', 'ubuntu' : {
        $shell_real = '/usr/sbin/nologin'
      }
      default : {
        $shell_real = '/sbin/nologin'
      }
    }
  } else {
    $shell_real = $shell
  }

  if versioncmp($clientversion, '3.6') == 1 {
    $real_purge_ssh_keys = $purge_ssh_keys
  } else {
    $real_purge_ssh_keys = undef
  }
  user { $name:
    ensure         => $ensure,
    shell          => $shell_real,
    comment        => $comment,
    home           => $home,
    uid            => $uid,
    gid            => $gid,
    groups         => $groups,
    password       => $password,
    managehome     => $managehome,
    purge_ssh_keys => $real_purge_ssh_keys,
  }

  if $gid =~ /^\d+$/ {
    group { $name:
      ensure => $ensure,
      gid    => $gid,
    }
  }

  if $ensure == 'present' {
    if ($managedefaultgroup and $gid) or $gid =~ /^\d+$/ {
      Group[$usergroupname] -> User[$name]
    }
    if $managehome {
      accounts::home_dir { $home:
        user    => $name,
        group   => $usergroupname,
        require => [ User[$name], ],
      }
    }
    if ($default_root_sudo) {
      accounts::sudoers { "${name}_root":
        ensure => 'present',
        user => $name,
        tags => [ 'NOPASSWD' ],
      }
    }
    if $ssh_keys_location {
      $real_ssh_keys_location = regsubst($ssh_keys_location, '%u', $name)
      file { $real_ssh_keys_location:
        ensure => file,
        owner => $name,
        group => $usergroupname,
        mode => '0600',
        replace => false,
      }
      $ssh_keys_require = File[$real_ssh_keys_location]
    } else {
      $real_ssh_keys_location = undef
      $ssh_keys_require = Accounts::Home_dir[$home]
    }
    create_resources('ssh_authorized_key', make_hash($ssh_keys, "${name}_"), {
      user => $name,
      require => $ssh_keys_require,
      target => $real_ssh_keys_location,
    })
    create_resources('exfile',
      make_hash(concat($defaultfiles,$files), "${name}_", 'path'), {
        basedir => $home,
        owner => $uid,
        group => $gid,
      }
    )
    create_resources('accounts::sudoers', make_hash($sudoers, "${name}_"),
        { user => $name, })

    create_resources('accounts::ssh_remote_access',
      make_hash($ssh_remote_access, "${name}_"), {
        homedir => $home,
        user => $name,
        group => $gid,
      }
    )
  }
  if $ensure == 'absent' {
    if ($managedefaultgroup and $gid) or $gid =~ /^\d+$/ {
      User[$name] -> Group[$usergroupname]
    }
    if $managehome == true {
      file { $home:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
  }

}
