class nova::lxc {

  package {'nova-compute-lxc':
    ensure => installed,
  }
}
