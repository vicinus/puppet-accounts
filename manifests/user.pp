define accounts::user(
  $ensure = 'present',
  $uid = undef,
  $gid = undef,
  $shell = '/bin/bash',
  $comment = $name,
  $home = "/home/${name}",
  $groups = [],
  $password = '!',
  $locked = false,
  $managehome = true,
  $managedefaultgroup = true,
  $ssh_keys = [],
  $files = [],
  $default_root_sudo = false,
  $sudoers = [],
) {
  validate_re($ensure, '^(present|absent)$')
  if $uid != undef {
    validate_re($uid, '^\d+$')
  }
  if $gid != undef {
    validate_re($gid, '^\d+$')
  }
  validate_re($shell, '^/')
  validate_string($comment)
  validate_re($home, '^/')
  validate_array($groups)
  if $password != undef {
    validate_string($password)
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

  user { $name:
    ensure => $ensure,
    shell => $shell_real,
    comment => $comment,
    home => $home,
    uid => $uid,
    gid => $gid,
    groups => $groups,
    password => $password,
    managehome => $managehome,
  }
 
  if $managedefaultgroup {
    group { $name:
      ensure => $ensure,
      gid    => $gid,
    }
  }

  if $ensure == "present" {
    Group[$name] -> User[$name]
    if $managehome {
      accounts::home_dir { $home:
        user => $name,
        uid => $uid,
        gid => $gid,
        require => [ User[$name], Group[$name] ],
      }
    }
    $sudo_resource = $accounts::sudo_resource
    if ($default_root_sudo) {
      create_resources($sudo_resource, { "${name}_root" => {
        ensure => 'present',
        users => $name,
        tags => [ 'NOPASSWD' ],
      }})
    }
    create_resources('ssh_authorized_key', make_hash($ssh_keys, "${name}_"), { user => $name, require => Accounts::Home_dir[$home] })
    create_resources('accounts::file', make_hash($files, "${name}_", 'path'), { basedir => $home, owner => $uid, group => $gid })
    create_resources($sudo_resource, make_hash($sudoers, "${name}_"), { users => $name})
  }
  if $ensure == "absent" {
    User[$name] -> Group[$name]
    if $managehome == true {
      file { $home:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
  }

}
