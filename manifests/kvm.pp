class nova::kvm($gid) {

  package {'nova-compute-kvm':
    ensure  => installed,
    require => Package['nova-common'],
    tag     => 'openstack',
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
