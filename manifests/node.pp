class nova::node (
  $nova_uid,
  $instances_mount=undef,
  $extra_config={},
  $libvirt_config={},
  $vncserver_proxyclient_address=$ipaddress,
  $routing_source_ip=$ipaddress,
  $metadata_workers=1,
  $driver='libvirt.LibvirtDriver',
  $libvirt_type='kvm',
  $default_networks=false,
)
{

  require nova

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')
  $use_conductor = hiera('nova::use_conductor', false)
  $send_notifications = hiera('nova::send_notifications', true)
  $icehouse_compat = hiera('nova::icehouse_compat', false)
  $use_neutron = hiera('nova::use_neutron', false)
  $neutron_url = hiera('nova::neutron_url', 'http://localhost:9696')
  $cinder_endpoint_template = hiera('nova::cinder_endpoint_template', false)

  include memcached::python
  include mysql::python

  package {'nova-common':
    ensure  => present,
    require => User['nova'],
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
    require => Package['nova-common'],
    content => template("nova/${openstack_version}/nova.conf-compute.erb"),
  }

  file { '/etc/nova/nova-compute.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    require => Package['nova-common'],
    content => template("nova/${openstack_version}/nova-compute.conf.erb"),
  }

  case $libvirt_type {
    'kvm':   { include nova::kvm }
    'lxc':   { include nova::lxc }
    default: {  }
  }

  include nova::libvirt
  include nova::compute

  if $openstack_version == 'juno' {
    file {'/usr/lib/python2.7/dist-packages/nova/openstack/common/rpc/':
      ensure => absent,
      force  => true,
    }
  }

  if !$use_neutron {
    include nova::network
    include nova::api-metadata

    file { '/etc/nova/api-paste.ini':
      ensure  => present,
      owner   => nova,
      group   => nova,
      mode    => '0640',
      content => template("nova/${openstack_version}/api-paste.ini.erb"),
      notify  => Service['nova-api-metadata'],
      require => Package['nova-api-metadata'],
    }

  } else {
    package{['nova-network', 'nova-api-metadata']:
      ensure => absent,
    }
  }
}
