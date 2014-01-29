class nova::kvm($gid) {

  package {'nova-compute-kvm':
    ensure => installed,
  }

  file { '/dev/kvm':
    group   => kvm,
    mode    => '0770',
    require => Group['kvm'],
  }

  group { 'kvm':
    ensure => present,
    gid    => $gid,
  }

}
