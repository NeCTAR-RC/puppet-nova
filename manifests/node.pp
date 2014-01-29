class nova::node (
  $nova_uid,
  $instances_mount=undef,
  $extra_config={},
  $vncserver_proxyclient_address=$ipaddress,
  $libvirt_type='kvm')
{

  require nova

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')

  realize Package['python-memcache']
  realize Package['python-mysqldb']

  if $instances_mount {

    package { 'nfs-common':
      ensure => installed,
    }

    mount { '/var/lib/nova/instances':
      device  => $instances_mount,
      fstype  => hiera('nfs::type', 'nfs'),
      ensure  => mounted,
      options => hiera('nfs::options', '_netdev,auto'),
      atboot  => true,
      require => [ Package['nova-compute'],
                   Package['nfs-common']],
    }
  }
  group { 'nova':
    ensure => present,
  }

  user { 'nova':
    ensure     => present,
    uid        => $nova_uid,
    gid        => nova,
    groups     => ['libvirtd'],
    shell      => '/bin/bash',
    home       => '/var/lib/nova',
    managehome => false,
    require    => [ Package['libvirt-bin'],
                    Group['nova']],
  }

  file { '/etc/nova/nova.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    require => Package['nova-compute'],
    content => template("nova/${openstack_version}/nova.conf-compute.erb"),
  }

  file { '/etc/nova/nova-compute.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    require => Package['nova-compute'],
    content => template("nova/${openstack_version}/nova-compute.conf.erb"),
  }

  case $libvirt_type {
    'kvm':   { include nova::kvm }
    'lxc':   { include nova::lxc }
    default: {  }
  }

  include nova::libvirt
  include nova::network

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    content => template("nova/${openstack_version}/api-paste.ini.erb"),
    notify  => Service['nova-api-metadata'],
    require => Package['nova-api-metadata'],
  }

}
