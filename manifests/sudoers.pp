define accounts::sudoers (
  $user = undef,
  $group = undef,
  $hosts = 'ALL',
  $cmnds = 'ALL',
  $comment = undef,
  $ensure = 'present',
  $runas = 'root',
  $tags = [],
  $defaults = [],
  $sudoersd = undef,
) {
  include ::accounts
  validate_re($name, '^[a-z_][a-z0-9_-]*$')
  validate_re($ensure, '^(present|absent)$')
  if $sudoersd {
    $sudoers_filename = "${sudoersd}/${name}"
  } else {
    $sudoers_filename = "${accounts::sudoersd}/${name}"
  }
  if $user == undef and $group == undef {
    fail('Either users or group must be set.')
  }
  if $user != undef and $group != undef {
    fail('Only users or group can be set, not both.')
  }

  if $group {
    validate_re($group, '^[a-z_][a-z0-9_-]*$')
  }

  if $user and !is_array($user) {
    validate_re($user, '^[a-z_][a-z0-9_-]*$')
  }

  if $ensure == 'present' {
    if (!$clientversion or versioncmp($clientversion, '3.5') == 1) and (!$serverversion or versioncmp($serverversion, '3.5') == 1) {
      $validate_cmd = '/usr/sbin/visudo -c -f %'
    } else {
      $validate_cmd = undef
      validate_cmd(template('accounts/sudoers.erb'), '/usr/sbin/visudo -c -f', 'visudo failed for sudoers')
    }

    file { $sudoers_filename:
      ensure       => file,
      content      => template('accounts/sudoers.erb'),
      owner        => 'root',
      group        => 'root',
      mode         => '0440',
      validate_cmd => $validate_cmd,
    }
  } else {
    file { $sudoers_filename:
      ensure => absent,
    }
  }
}
