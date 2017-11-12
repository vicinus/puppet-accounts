# See README.md for details.
define accounts::group (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Variant[Pattern[/^\d+$/],Integer]] $gid = undef,
  Optional[Boolean] $system = undef,
  Array $sudoers = [],
) {
  group { $title:
    ensure => $ensure,
    gid    => $gid,
    system => $system,
  }

  create_resources('accounts::sudoers', make_hash($sudoers, $title), {
    ensure => $ensure,
    users  => "%${title}",
  })
}
