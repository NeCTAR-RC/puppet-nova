class nova::kvm($gid, $package_ensure='installed') {

  package {'nova-compute-kvm':
    ensure  => $package_ensure,
    require => Package['nova-common'],
    tag     => 'openstack',
  }

  file { '/dev/kvm':
    group   => kvm,
    mode    => '0660',
    require => Group['kvm'],
  }

  group { 'kvm':
    ensure => present,
    gid    => $gid,
  }

}
