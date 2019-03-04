# See README.md for details.
define accounts::ssh_config (
  String $username,
  Enum['present', 'absent'] $ensure = 'present',
  Optional[Variant[Array[String],String]] $host = undef,
  Optional[String] $hostname = undef,
  Optional[Stdlib::Unixpath] $homedir = undef,
  Optional[Variant[Integer, String]] $order = undef,
  Optional[Variant[String, Sensitive]] $key = undef,
  Optional[String] $group = undef,
  Boolean $manage_ssh_config = true,

  Optional[String] $address_family = undef,
  Optional[String] $batch_mode = undef,
  Optional[String] $bind_address = undef,
  Optional[String] $canonical_domains = undef,
  Optional[String] $canonicalize_fallback_local = undef,
  Optional[String] $canonicalize_hostname = undef,
  Optional[String] $canonicalize_max_dots = undef,
  Optional[String] $canonicalize_permitted_cnames = undef,
  Optional[String] $challenge_response_authentication = undef,
  Optional[String] $check_host_ip = undef,
  Optional[String] $cipher = undef,
  Optional[String] $clear_all_forwardings = undef,
  Optional[String] $compression = undef,
  Optional[String] $compression_level = undef,
  Optional[String] $connection_attempts = undef,
  Optional[String] $connect_timeout = undef,
  Optional[String] $control_master = undef,
  Optional[String] $control_path = undef,
  Optional[String] $control_persist = undef,
  Optional[String] $dynamic_forward = undef,
  Optional[String] $enable_ssh_keysign = undef,
  Optional[String] $escape_char = undef,
  Optional[String] $exit_on_forward_failure = undef,
  Optional[String] $fingerprint_hash = undef,
  Optional[String] $forward_agent = undef,
  Optional[String] $forward_x11 = undef,
  Optional[String] $forward_x11_timeout = undef,
  Optional[String] $forward_x11_trusted = undef,
  Optional[String] $gateway_ports = undef,
  Optional[String] $global_known_hosts_file = undef,
  Optional[String] $gssapi_authentication = undef,
  Optional[String] $gssapi_key_exchange = undef,
  Optional[String] $gssapi_client_identity = undef,
  Optional[String] $gssapi_server_identity = undef,
  Optional[String] $gssapi_delegate_credentials = undef,
  Optional[String] $gssapi_renewal_forces_rekey = undef,
  Optional[String] $gssapi_trust_dns = undef,
  Optional[String] $hash_known_hosts = undef,
  Optional[String] $hostbased_authentication = undef,
  Optional[String] $hostbased_key_types = undef,
  Optional[String] $host_key_algorithms = undef,
  Optional[String] $host_key_alias = undef,
  Optional[String] $host_name = undef,
  Optional[String] $identities_only = undef,
  Optional[String] $identity_file = undef,
  Optional[String] $ignore_unknown = undef,
  Optional[String] $ipqos = undef,
  Optional[String] $kbd_interactive_authentication = undef,
  Optional[String] $kbd_interactive_devices = undef,
  Optional[String] $kex_algorithms = undef,
  Optional[String] $local_command = undef,
  Optional[String] $local_forward = undef,
  Optional[String] $log_level = undef,
  Optional[String] $macs = undef,
  Optional[String] $no_host_authentication_for_localhost = undef,
  Optional[String] $number_of_password_prompts = undef,
  Optional[String] $password_authentication = undef,
  Optional[String] $permit_local_command = undef,
  Optional[String] $pkcs11_provider = undef,
  Optional[String] $port = undef,
  Optional[String] $preferred_authentications = undef,
  Optional[String] $protocol = undef,
  Optional[String] $proxy_command = undef,
  Optional[String] $proxy_use_fdpass = undef,
  Optional[String] $pubkey_authentication = undef,
  Optional[String] $rekey_limit = undef,
  Optional[String] $remote_forward = undef,
  Optional[String] $request_tty = undef,
  Optional[String] $revoked_host_keys = undef,
  Optional[String] $rhosts_rsa_authentication = undef,
  Optional[String] $rsa_authentication = undef,
  Optional[String] $send_env = undef,
  Optional[String] $server_alive_count_max = undef,
  Optional[String] $server_alive_interval = undef,
  Optional[String] $stream_local_bind_mask = undef,
  Optional[String] $stream_local_bind_unlink = undef,
  Optional[String] $strict_host_key_checking = undef,
  Optional[String] $tcp_keep_alive = undef,
  Optional[String] $tunnel = undef,
  Optional[String] $tunnel_device = undef,
  Optional[String] $update_host_keys = undef,
  Optional[String] $use_privileged_port = undef,
  Optional[String] $user = undef,
  Optional[String] $user_known_hosts_file = undef,
  Optional[String] $verify_host_key_dns = undef,
  Optional[String] $visual_host_key = undef,
  Optional[String] $xauth_location = undef,
  Optional[String] $pubkey_accepted_key_types = undef,
) {
  if $homedir {
    $_homedir = $homedir
  } else {
    if $username == 'root' {
      $_homedir = '/root'
    } else {
      $_homedir = "/home/${username}"
    }
  }
  if $identity_file {
    if $identity_file[0] == '/' {
      $_identity_file = $identity_file
    } else {
      $_identity_file = "${_homedir}/.ssh/${identity_file}"
    }
  } elsif $key != undef {
    $_identity_file = "${_homedir}/.ssh/${name}.key"
  } else {
    $_identity_file = undef
  }
  if $key  != undef {
    if $key =~ Sensitive {
      $_key = $key.unwrap
    } else {
      $_key = $key
    }
    file { $_identity_file:
      ensure  => $ensure,
      owner   => $username,
      group   => $group,
      mode    => '0600',
      require => Accounts::Home_dir[$_homedir],
      content => "${_key}\n",
    }
  }

  if $manage_ssh_config {
    concat::fragment { "${title}_ssh_config":
      target  => "${_homedir}/.ssh/config",
      content => template('accounts/ssh_config.erb'),
      order   => $order,
    }
  }
}
