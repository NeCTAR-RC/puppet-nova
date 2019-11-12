# Base class for a nova controller, sets up nova.conf
class nova::cloudcontroller(
  $extra_config={},
  $pci_alias=undef,
  $default_networks=false,
)
{

  require nova

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')
  $conductor_workers = hiera('nova::conductor::workers', 0)
  $upgrade_level = hiera('nova::upgrade_level', false)
  $neutron_url = hiera('nova::neutron_url', 'http://localhost:9696')
  $cinder_endpoint_template = hiera('nova::cinder_endpoint_template', false)
  $api_db_connection = hiera('nova::db::api_database_connection')
  $restrict_zones = hiera('nova::restrict_zones', false)

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
    ensure => installed,
  }

  file { '/etc/nova/nova.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    content => template("nova/${openstack_version}/nova.conf-cell.erb"),
    require => Package['nova-common'],
  }

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    content => template("nova/${openstack_version}/api-paste.ini.erb"),
    require => Package['nova-common'],
  }

  file { '/etc/nova/policy.yaml':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    source  => "puppet:///modules/nova/${openstack_version}/policy.yaml",
    require => Package['nova-common'],
  }

}
