# See README.md for details.
define accounts::sudoers (
  Enum['present', 'absent'] $ensure = 'present',
  String $filename = $title,
  Optional[String] $users = undef,
  String $hosts = 'ALL',
  String $cmnds = 'ALL',
  Optional[String] $comment = undef,
  String $runas = 'root',
  Array[String] $tags = [],
  Array[String] $defaults = [],
  Array[String] $host_defaults = [],
  Array[String] $user_defaults = [],
  Array[String] $cnmd_defaults = [],
  Array[String] $runas_defaults = [],
  Optional[String] $sudoersd = undef,
  Optional[Variant[String, Integer]] $order = undef,
  Boolean $sudoers_fragment = false,
) {
  include ::accounts::sudo
  if $sudoersd {
    $sudoers_filename = "${sudoersd}/${filename}"
  } else {
    $sudoers_filename = "${accounts::sudo::sudoersd}/${filename}"
  }

  if $ensure == 'present' {
    if $sudoers_fragment {
      concat::fragment { $name:
        target  => $sudoers_fragment,
        content => template('accounts/sudoers.erb'),
        order   => $order,
      }
    } else {
      file { $sudoers_filename:
        ensure       => file,
        content      => template('accounts/sudoers.erb'),
        owner        => 'root',
        group        => 'root',
        mode         => '0440',
        validate_cmd => '/usr/sbin/visudo -c -f %',
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
