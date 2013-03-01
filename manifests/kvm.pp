class nova::kvm($gid) {

  file { '/dev/kvm':
    group   => kvm,
    mode    => '0770',
    require => Group['kvm'],
  }

  group { 'kvm':
    ensure => present,
    gid    => $gid,
  }

  package {'kvm-ipxe':
    ensure => installed,
  }
  
}
