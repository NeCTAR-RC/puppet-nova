class nova::kvm {

  file { '/dev/kvm':
    group   => kvm,
    mode    => '0770',
    require => Group['kvm'],
  }

  group { 'kvm':
    ensure => present,
    gid    => $kvm_gid,
  }

}
