define accounts::sudoers (
  $user = undef,
  $group = undef,
  $hosts = 'ALL',
  $cmnds = 'ALL',
  $comment = undef,
  $ensure = 'present',
  $runas = 'root',
  $tags = [],
  $host_defaults = [],
  $user_defaults = [],
  $cnmd_defaults = [],
  $runas_defaults = [],
  $sudoersd = undef,
  $order = undef,
  $sudoers_fragment = false,
) {
  include ::accounts::sudo
  validate_re($name, '^[a-z_][a-zA-Z0-9_-]*$')
  validate_re($ensure, '^(present|absent)$')
  if $sudoersd {
    $sudoers_filename = "${sudoersd}/${name}"
  } else {
    $sudoers_filename = "${accounts::sudo::sudoersd}/${name}"
  }
  if $user == undef and $group == undef {
    fail('Either users or group must be set.')
  }
  if $user != undef and $group != undef {
    fail('Only users or group can be set, not both.')
  }

  if $group {
    validate_re($group, '^[a-z_][a-z0-9_-]*$')
    $real_user = "%${group}"
  }

  if $user {
    if !is_array($user) {
      validate_re($user, '^[a-z_][a-z0-9_-]*$')
    }
    $real_user = $user
  }

  if $ensure == 'present' {
    if (!$clientversion or versioncmp($clientversion, '3.5') == 1) and (!$serverversion or versioncmp($serverversion, '3.5') == 1) {
      $validate_cmd = '/usr/sbin/visudo -c -f %'
    } else {
      $validate_cmd = undef
      validate_cmd(template('accounts/sudoers.erb'), '/usr/sbin/visudo -c -f', 'visudo failed for sudoers')
    }

    if $sudoers_fragment {
      concat::fragment { $name:
        target => $sudoers_fragment,
        content => template('accounts/sudoers.erb'),
        order => $order,
      }
    } else {
      file { $sudoers_filename:
        ensure       => file,
        content      => template('accounts/sudoers.erb'),
        owner        => 'root',
        group        => 'root',
        mode         => '0440',
        validate_cmd => $validate_cmd,
      }
    }
  } else {
    if ! $sudoers_fragment {
      file { $sudoers_filename:
        ensure => absent,
      }
    }
  }
}
