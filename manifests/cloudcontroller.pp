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

  file { "/etc/nova/policy.yaml":
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    source  => "puppet:///modules/nova/${openstack_version}/policy.yaml",
    require => Package['nova-common'],
  }

}
