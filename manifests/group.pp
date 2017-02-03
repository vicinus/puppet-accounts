# See README.md for details.
define accounts::group (
  $ensure = 'present',
  $gid = undef,
  $system = undef,
  $sudoers = [],
) {
  validate_re($ensure, '^(present|absent)$')
  if $gid != undef {
    validate_integer($gid)
  }

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
