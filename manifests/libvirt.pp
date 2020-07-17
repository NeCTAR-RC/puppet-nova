# Libvirt specifics for nova
class oldnova::libvirt{

  ensure_packages(['ebtables', 'pm-utils', 'genisoimage'])

  $uid = hiera('nova::libvirt::uid')
  $host_uuid = hiera('nova::libvirt::host_uuid', false)
  $config = hiera('nova::libvirt::config', {})
  $qemu_config = hiera('nova::libvirt::qemu_config', {})
  $openstack_version = hiera('openstack_version')

  if $openstack_version[0] > 'n' {
    $libvirt_service = 'libvirtd'
  } else {
    $libvirt_service = 'libvirt-bin'
  }

  package { 'libvirt-bin':
    ensure  => present,
    require => User['libvirt-qemu'],
  }

  service { $libvirt_service:
    ensure => running,
  }

  user { 'libvirt-qemu':
    ensure     => present,
    uid        => $uid,
    gid        => 'kvm',
    shell      => '/usr/sbin/nologin',
    home       => '/var/lib/libvirt',
    managehome => false,
  }

  # For xenial it uses the old group name
  if $::lsbdistcodename == 'xenial' {
    group {'libvirtd':
      ensure => present,
      system => true,
    }
  }
  # Ensure this is also on xenial for things like ceilometer module
  # that expect it to exist
  group {'libvirt':
    ensure => present,
    system => true,
  }

  # This is used in the template
  if $::lsbdistcodename == 'xenial' {
    $libvirt_group = 'libvirtd'
  } else {
    $libvirt_group = 'libvirt'
  }

  file { '/etc/libvirt/libvirtd.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("oldnova/libvirtd.conf-${::lsbdistcodename}.erb"),
    notify  => Service[$libvirt_service],
    require => Package['libvirt-bin'],
  }

  file { '/etc/libvirt/qemu.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('oldnova/qemu.conf.erb'),
    notify  => Service[$libvirt_service],
    require => Package['libvirt-bin'],
  }

  file { "/etc/default/${$libvirt_service}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => ["puppet:///modules/oldnova/libvirt-bin-${::lsbdistcodename}",
                'puppet:///modules/oldnova/libvirt-bin'],
    notify  => Service[$libvirt_service],
    require => Package['libvirt-bin'],
  }

  # delete the current virbr0 interface if it exists
  exec { 'virsh-net-destroy-default':
    command => '/usr/bin/virsh net-destroy default',
    onlyif  => '/sbin/ip address show dev virbr0',
    notify  => Exec['virsh-net-undefine-default'],
  }

  # undefine the 'default' network if it is defined
  exec { 'virsh-net-undefine-default':
    command => '/usr/bin/virsh net-undefine default',
    onlyif  => '/usr/bin/test -e /etc/libvirt/qemu/networks/default.xml',
    require => Package['libvirt-bin'],
  }

}
