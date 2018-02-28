# See README.md for details.
define accounts::group (
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Variant[Pattern[/^\d+$/],Integer]] $gid = undef,
  Optional[Boolean] $system = undef,
  Array $sudoers = [],
) {
  ensure_resource('group', $title, {
    ensure => $ensure,
    gid    => $gid,
    system => $system,
  })

  create_resources('accounts::sudoers',
    make_hash($sudoers, {
      'keyprefix' => $title,
      'keyname'   => 'filename',
    }),
  {
    ensure => $ensure,
    users  => "%${title}",
  })
}
