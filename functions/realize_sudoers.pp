function accounts::realize_sudoers (
  Optional[Variant[String,Array[String],Hash[String,Variant[String,Array[String]]]]] $list = undef,
) {
  if $list != undef {
    if $list =~ String {
      Accounts::Sudoers <| tag == $list |>
    } elsif $list =~ Array[String] {
      $list.each |$item| {
        Accounts::Sudoers <| tag == $item |>
      }
    } else {
      $list.each |$item| {
        $usertag = $item[0]
        $sudoerstags = $item[1]
        if $sudoerstags =~ String {
          $sudoerstag = $sudoerstags
          Accounts::Sudoers <| tag == $usertag and tag == $sudoerstag |>
        } else {
          $sudoerstags.each |$sudoerstag| {
            Accounts::Sudoers <| tag == $usertag and tag == $sudoerstag |>
          }
        }
      }
    }
  }
}
