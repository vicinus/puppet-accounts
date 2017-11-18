# See README.md for details.
define accounts::sudoers (
  Enum['present', 'absent'] $ensure = 'present',
  String $filename = $title,
  Optional[String] $comment = undef,
  Optional[Variant[String,Array[String]]] $users = undef,
  Optional[Variant[String,Array[String]]] $hosts = 'ALL',
  Optional[Variant[String,Array[String]]] $cmnds = 'ALL',
  Optional[Variant[String,Array[String]]] $runas = 'root',
  Array[String] $tags = [],
  Variant[String,Array[String]] $defaults = [],
  Variant[String,Array[String]] $host_defaults = [],
  Variant[String,Array[String]] $user_defaults = [],
  Variant[String,Array[String]] $cnmd_defaults = [],
  Variant[String,Array[String]] $runas_defaults = [],
  Optional[String] $sudoersd = undef,
  Optional[Variant[String, Integer]] $order = undef,
  Boolean $sudoers_fragment = false,
) {
  include ::accounts::sudo
  $_filename = regsubst($filename, '\.', '_', 'G')
  if $sudoersd {
    $sudoers_filename = "${sudoersd}/${_filename}"
  } else {
    $sudoers_filename = "${accounts::sudo::sudoersd}/${_filename}"
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
