class nova::kvm($gid, $package_ensure='installed') {

  $openstack_version = hiera('openstack_version')

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

  if $openstack_version == 'stein' {
    apt::pin { 'qemu':
      packages   => 'qemu-*',
      originator => 'Ubuntu',
      priority   => 1000,
    }
  }

}
