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
  $remove_unused_base_images=false,
  $my_ip=undef,
)
{

  require nova

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')
  $send_notifications = hiera('nova::send_notifications', true)
  $neutron_url = hiera('nova::neutron_url', 'http://localhost:9696')
  $cinder_endpoint_template = hiera('nova::cinder_endpoint_template', false)
  $upgrade_level = hiera('nova::upgrade_level', false)

  if $cell_config['novncproxy_base_url'] {
    $novncproxy_base_url = $cell_config['novncproxy_base_url']
  } else {
    $vnc_host = $cell_config['vnc_host']
    $novncproxy_base_url = "http://${vnc_host}:6080/vnc_auto.html"
  }

  nag::unused_variable{'nova::use_conductor':}
  nag::unused_variable{'nova::cell_type':}
  nag::unused_variable{'nova::cell_name':}
  $unused_cell_variables = ['nova::cell_config.use_cells',
                            'nova::cell_config.cells_instance_updated_at_threshold',
                            'nova::cell_config.cells_instance_update_num_instances',
                            'nova::cell_config.cells_capabilities',
                            'nova::cell_config.cells_expire_reservations',
                            'nova::cell_config.cells_scheduler_direct_only_cells',
                            'nova::cell_config.cells_heal_update_number',
                            'nova::cell_config.capacity_aggregate_key',
                            'nova::cell_config.reserve_percent',
                            'nova::cell_config.free_disk_units_needed',
                            'nova::cell_config.cells_enable',
                            ]
  nag::unused_variable{$unused_cell_variables:
    merge_strategy => 'deep',
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
    content => template("nova/${openstack_version}/nova.conf-compute.erb"),
  }

  file { '/etc/nova/nova-compute.conf':
    ensure  => present,
    owner   => 'nova',
    group   => 'nova',
    mode    => '0640',
    require => Package['nova-common'],
    content => template("nova/${openstack_version}/nova-compute.conf.erb"),
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
    source  => "puppet:///modules/nova/${openstack_version}/${policy_file}",
    require => Package['nova-common'],
  }

  case $libvirt_type {
    'kvm':   { include ::nova::kvm }
    default: {  }
  }

  include ::nova::libvirt
  include ::nova::compute

}
