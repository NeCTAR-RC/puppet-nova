class nova::libvirt {

  package { 'libvirt-bin':
    ensure  => present,
    require => User['libvirt-qemu'],
  }

  package {'pm-utils':
    ensure => installed,
  }
  
  service { 'libvirt-bin':
    ensure => running,
  }

  user { 'libvirt-qemu':
    ensure     => present,
    uid        => $libvirt_uid,
    gid        => 'kvm',
    shell      => '/bin/false',
    home       => '/var/lib/libvirt',
    managehome => false,
  }

  file { '/etc/libvirt/libvirtd.conf':
    ensure  => present,
    source  => 'puppet:///modules/nova/libvirtd.conf',
    notify  => Service['libvirt-bin'],
    require => Package['libvirt-bin'],
  }

  file { '/etc/default/libvirt-bin':
    ensure  => present,
    source  => 'puppet:///modules/nova/libvirt-bin',
    notify  => Service['libvirt-bin'],
    require => Package['libvirt-bin'],
  }

  # Remove the default configured dnsmasq network.
  file {'/etc/libvirt/qemu/networks/autostart/':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Service['libvirt-bin'],
    require => Package['libvirt-bin'],
  }
}
