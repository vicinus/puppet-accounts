# See README.md for details.
define accounts::user (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Variant[Integer, Pattern[/^\d+$/]]] $uid = undef,
  Optional[Variant[Integer, String]] $gid = undef,
  Stdlib::Unixpath $shell = '/bin/bash',
  Optional[String] $comment = undef,
  Stdlib::Unixpath $home = "/home/${name}",
  Array[String, Integer] $groups = [],
  Optional[String] $password = undef,
  Boolean $locked = false,
  Boolean $managehome = true,
  Boolean $manage_home_dir = true,
  Optional[Stdlib::Filemode] $home_default_mode = undef,
  Boolean $managedefaultgroup = true,
  Array $ssh_keys = [],
  Optional[Stdlib::Unixpath] $ssh_keys_location = undef,
  Boolean $purge_ssh_keys = true,
  Boolean $purge_home_directory = false,
  Boolean $purge_ssh_directory = false,
  Hash $ssh_known_hosts = {},
  Array $files = [],
  Array $defaultfiles = [],
  Boolean $merge_file_hashes = false,
  Boolean $default_root_sudo = false,
  Array $sudoers = [],
  Array $virtual_sudoers = [],
  Array $ssh_config = [],
  Optional[Boolean] $manage_ssh_config = undef,
  Enum['inclusive', 'minimum'] $membership = 'inclusive',
) {
  include ::accounts
  if $manage_ssh_config == undef {
    $_manage_ssh_config = $::accounts::manage_ssh_config
  } else {
    $_manage_ssh_config = $manage_ssh_config
  }
  case $gid {
    /^\d+$/, Integer[0]: {
      $usergroupname = $name
      $gid_is_number = true
    }
    default: {
      $usergroupname = $gid
      $gid_is_number = false
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
    membership     => $membership,
    purge_ssh_keys => $purge_ssh_keys,
  }

  if $gid and $gid_is_number {
    group { $name:
      ensure => $ensure,
      gid    => $gid,
    }
  }

  if $ensure == 'present' {
    if $gid != undef and ($managedefaultgroup or $gid_is_number) {
      Group[$usergroupname] -> User[$name]
    }
    if $managehome {
      accounts::home_dir { $home:
        user                   => $name,
        group                  => $usergroupname,
        manage_ssh_config      => $_manage_ssh_config,
        manage_home_dir        => $manage_home_dir,
        default_mode           => $home_default_mode,
        purge_home_directory   => $purge_home_directory,
        purge_ssh_directory    => $purge_ssh_directory,
        ssh_known_hosts        => $ssh_known_hosts,
        create_authorized_keys => $ssh_keys_location == undef,
        require                => [ User[$name], ],
      }
    }
    if ($default_root_sudo) {
      accounts::sudoers { "${name}_root":
        ensure => 'present',
        users  => $name,
        tags   => [ 'NOPASSWD' ],
      }
    }
    if $ssh_keys_location {
      $_ssh_keys_location = regsubst($ssh_keys_location, '%u', $name)
      file { $_ssh_keys_location:
        ensure  => file,
        owner   => $name,
        group   => $usergroupname,
        mode    => '0600',
        replace => false,
      }
      $ssh_keys_require = File[$_ssh_keys_location]
    } else {
      $_ssh_keys_location = undef
      if $managehome {
        $ssh_keys_require = Accounts::Home_dir[$home]
      } else {
        $ssh_keys_require = undef
      }
    }
    create_resources('ssh_authorized_key',
      make_hash($ssh_keys, {
        'keyprefix' => $name,
        'keyname' => 'name',
      }), {
      user => $name,
      require => $ssh_keys_require,
      target => $_ssh_keys_location,
    })
    if $merge_file_hashes {
      $merge_items = { 'merge_items' => true, }
    } else {
      $merge_items = { }
    }
    create_resources('exfile',
      make_hash(concat($defaultfiles,$files), merge({
        'keyprefix' => $name,
        'keyname' => 'path',
      }, $merge_items)), {
        basedir => $home,
        owner => $uid,
        group => $gid,
        additional_parameters => { 'name' => $title },
      }
    )
    if !empty($virtual_sudoers) {
      create_resources('@accounts::sudoers', make_hash($virtual_sudoers, "virtual_${name}"),
          { users => $name, })
    }
    if !empty($sudoers) {
      create_resources('accounts::sudoers', make_hash($sudoers, $name),
          { users => $name, })
    }

    create_resources('accounts::ssh_config',
      make_hash($ssh_config, $name), {
        homedir => $home,
        username => $name,
        manage_ssh_config => $_manage_ssh_config,
        group => $gid,
      }
    )
  }
  if $ensure == 'absent' {
    if $gid != undef and ($managedefaultgroup or $gid_is_number) {
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
