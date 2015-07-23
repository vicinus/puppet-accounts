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
  $adduserdefaultgroup = false,
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
  if $gid != undef {
    if $adduserdefaultgroup {
      validate_re($gid, '^\d+$')
    }
  }
  validate_re($shell, '^/')
  validate_string($comment)
  validate_re($home, '^/')
  validate_array($groups)
  if $password != undef {
    validate_string($password)
  }
  if $adduserdefaultgroup {
    $usergroupname = $name
  } else {
   $usergroupname = $gid
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
    purge_ssh_keys => $purge_ssh_keys,
  }
 
  if $adduserdefaultgroup {
    group { $name:
      ensure => $ensure,
      gid    => $gid,
    }
  }

  if $ensure == "present" {
    if $managedefaultgroup {
      Group[$usergroupname] -> User[$name]
    }
    if $managehome {
      accounts::home_dir { $home:
        user => $name,
        uid => $uid,
        gid => $gid,
        require => [ User[$name], Group[$usergroupname] ],
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
    if $ssh_keys_location {
      $real_ssh_keys_location = regsubst($ssh_keys_location, '%u', $name)
    }
    create_resources('ssh_authorized_key', make_hash($ssh_keys, "${name}_"), { user => $name, require => Accounts::Home_dir[$home], target => $real_ssh_keys_location, })
    create_resources('exfile', make_hash(concat($defaultfiles,$files), "${name}_", 'path'), { basedir => $home, owner => $uid, group => $gid, })
    create_resources($sudo_resource, make_hash($sudoers, "${name}_"), { users => $name, })
    create_resources('accounts::ssh_remote_access', make_hash($ssh_remote_access, "${name}_"), { homedir => $home, user => $name, group => $gid, })
  }
  if $ensure == "absent" {
    if $managedefaultgroup {
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
