class oldnova::node {

  require oldnova

  $nova_uid = hiera('nova::node::nova_uid')
  $instances_mount = hiera('nova::node::instances_mount')
  $extra_config = hiera('nova::node::extra_config', {})
  $libvirt_config = hiera('nova::node::libvirt_config', {})
  $vncserver_proxyclient_address = hiera('nova::node::vncserver_proxyclient_address')
  $routing_source_ip = hiera('nova::node::routing_source_ip')
  $metadata_workers = hiera('nova::node::metadata_workers', 1)
  $driver = hiera('nova::node::driver', 'libvirt.LibvirtDriver')
  $libvirt_type = hiera('nova::node::libvirt_type', 'kvm')
  $default_networks = hiera('nova::node::default_networks', false)
  $remove_unused_base_images = hiera('nova::node::remove_unused_base_images', false)
  $my_ip = hiera('nova::node::my_ip')

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')
  $send_notifications = hiera('nova::send_notifications', true)
  $neutron_url = hiera('nova::neutron_url', 'http://localhost:9696')
  $cinder_endpoint_template = hiera('nova::cinder_endpoint_template', false)
  $upgrade_level = hiera('nova::upgrade_level', false)

  $keymgr_backend = hiera('nova::compute::keymgr_backend', undef)
  $barbican_auth_endpoint = hiera('nova::compute::barbican_auth_endpoint', undef)

  if $cell_config['novncproxy_base_url'] {
    $novncproxy_base_url = $cell_config['novncproxy_base_url']
  } else {
    $vnc_host = $cell_config['vnc_host']
    $novncproxy_base_url = "http://${vnc_host}:6080/vnc_auto.html"
  }

  include ::memcached::python

  package {'nova-common':
    ensure  => present,
    require => User['nova'],
    tag     => 'openstack',
  }

  group { 'nova':
    ensure => present,
  }

  if $::lsbdistcodename == 'xenial' {
    $libvirt_group = 'libvirtd'
  } else {
    $libvirt_group = 'libvirt'
  }

  user { 'nova':
    ensure     => present,
    uid        => $nova_uid,
    gid        => nova,
    groups     => [$libvirt_group],
    shell      => '/bin/bash',
    home       => '/var/lib/nova',
    managehome => false,
    require    => [ Package['libvirt-bin'],
                    Group['nova']],
  }

  file { '/etc/nova/nova.conf':
    ensure  => present,
    owner   => 'nova',
    group   => 'nova',
    mode    => '0640',
    require => Package['nova-common'],
    content => template("oldnova/${openstack_version}/nova.conf-compute.erb"),
  }

  file { '/etc/nova/nova-compute.conf':
    ensure  => present,
    owner   => 'nova',
    group   => 'nova',
    mode    => '0640',
    require => Package['nova-common'],
    content => template("oldnova/${openstack_version}/nova-compute.conf.erb"),
  }

  if $openstack_version[0] < 'o' {
    $policy_file = 'policy.json'
    $old_policy = 'policy.yaml'
  } else {
    $policy_file = 'policy.yaml'
    $old_policy = 'policy.json'
  }

  file { "/etc/nova/${old_policy}":
    ensure => absent,
  }

  file { "/etc/nova/${policy_file}":
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    source  => "puppet:///modules/oldnova/${openstack_version}/${policy_file}",
    require => Package['nova-common'],
  }

  case $libvirt_type {
    'kvm':   { include oldnova::kvm }
    default: {  }
  }

  include oldnova::libvirt
  include oldnova::compute

}
