class nova::libvirt($uid) {

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
    uid        => $uid,
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

  # delete the current virbr0 interface if it exists
  exec { 'virsh-net-destroy-default':
    command => '/usr/bin/virsh net-destroy default',
    onlyif  => '/sbin/ifconfig virbr0',
    notify  => Exec['virsh-net-undefine-default'],
  }

  # undefine the 'default' network if it is defined
  exec { 'virsh-net-undefine-default':
    command => '/usr/bin/virsh net-undefine default',
    onlyif  => '/usr/bin/test -e /etc/libvirt/qemu/networks/default.xml',
  }

}
