function accounts::data() {
  {
    'lookup_options' => {
      'accounts::managed_groups' => {
        'merge' => 'deep',
      },
      'accounts::managed_users_global_defaults' => {
        'merge' => 'deep',
      },
      'accounts::managed_users' => {
        'merge' => 'deep',
      },
      'accounts::managed_users_defaults' => {
        'merge' => 'deep',
      },
      'accounts::sudo::sudoers' => {
        'merge' => 'deep',
      },
    },
  }
}
