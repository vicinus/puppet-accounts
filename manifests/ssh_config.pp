# See README.md for details.
define accounts::ssh_config (
  $username,
  $host = undef,
  $homedir = undef,
  $ensure = 'present',
  $order = '10',
  $key = undef,
  $group = undef,
  $manage_ssh_config = undef,

  $address_family = undef,
  $batch_mode = undef,
  $bind_address = undef,
  $canonical_domains = undef,
  $canonicalize_fallback_local = undef,
  $canonicalize_hostname = undef,
  $canonicalize_max_dots = undef,
  $canonicalize_permitted_cnames = undef,
  $challenge_response_authentication = undef,
  $check_host_ip = undef,
  $cipher = undef,
  $clear_all_forwardings = undef,
  $compression = undef,
  $compression_level = undef,
  $connection_attempts = undef,
  $connect_timeout = undef,
  $control_master = undef,
  $control_path = undef,
  $control_persist = undef,
  $dynamic_forward = undef,
  $enable_ssh_keysign = undef,
  $escape_char = undef,
  $exit_on_forward_failure = undef,
  $fingerprint_hash = undef,
  $forward_agent = undef,
  $forward_x11 = undef,
  $forward_x11_timeout = undef,
  $forward_x11_trusted = undef,
  $gateway_ports = undef,
  $global_known_hosts_file = undef,
  $gssapi_authentication = undef,
  $gssapi_key_exchange = undef,
  $gssapi_client_identity = undef,
  $gssapi_server_identity = undef,
  $gssapi_delegate_credentials = undef,
  $gssapi_renewal_forces_rekey = undef,
  $gssapi_trust_dns = undef,
  $hash_known_hosts = undef,
  $hostbased_authentication = undef,
  $hostbased_key_types = undef,
  $host_key_algorithms = undef,
  $host_key_alias = undef,
  $host_name = undef,
  $identities_only = undef,
  $identity_file = undef,
  $ignore_unknown = undef,
  $ipqos = undef,
  $kbd_interactive_authentication = undef,
  $kbd_interactive_devices = undef,
  $kex_algorithms = undef,
  $local_command = undef,
  $local_forward = undef,
  $log_level = undef,
  $macs = undef,
  $no_host_authentication_for_localhost = undef,
  $number_of_password_prompts = undef,
  $password_authentication = undef,
  $permit_local_command = undef,
  $pkcs11_provider = undef,
  $port = undef,
  $preferred_authentications = undef,
  $protocol = undef,
  $proxy_command = undef,
  $proxy_use_fdpass = undef,
  $pubkey_authentication = undef,
  $rekey_limit = undef,
  $remote_forward = undef,
  $request_tty = undef,
  $revoked_host_keys = undef,
  $rhosts_rsa_authentication = undef,
  $rsa_authentication = undef,
  $send_env = undef,
  $server_alive_count_max = undef,
  $server_alive_interval = undef,
  $stream_local_bind_mask = undef,
  $stream_local_bind_unlink = undef,
  $strict_host_key_checking = undef,
  $tcp_keep_alive = undef,
  $tunnel = undef,
  $tunnel_device = undef,
  $update_host_keys = undef,
  $use_privileged_port = undef,
  $user = undef,
  $user_known_hosts_file = undef,
  $verify_host_key_dns = undef,
  $visual_host_key = undef,
  $xauth_location = undef,
) {
  if $homedir {
    $real_homedir = $homedir
  } else {
    $real_homedir = "/home/${username}"
  }
  if $identity_file {
    if $identity_file[0] == '/' {
      $real_identity_file = $identity_file
    } else {
      $real_identity_file = "${real_homedir}/.ssh/${identity_file}"
    }
  } elsif $key {
    $real_identity_file = "${real_homedir}/.ssh/${name}.key"
  } else {
    $real_identity_file = undef
  }
  if $key {
    file { $real_identity_file:
      ensure  => $ensure,
      owner   => $username,
      group   => $group,
      mode    => '0600',
      require => Accounts::Home_dir[$real_homedir],
      content => "${key}\n",
    }
  }

  if $manage_ssh_config {
    concat::fragment { "${title}_ssh_config":
      target  => "${real_homedir}/.ssh/config",
      content => template('accounts/ssh_config.erb'),
      order   => $order,
    }
  }
}
