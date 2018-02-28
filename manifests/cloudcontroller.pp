# Base class for a nova controller, sets up nova.conf
class nova::cloudcontroller(
  $extra_config={},
  $cell_type='compute',
)
{

  require nova

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')
  $use_conductor = hiera('nova::use_conductor', false)
  $conductor_workers = hiera('nova::conductor::workers', 0)
  $upgrade_level = hiera('nova::upgrade_level', false)
  $neutron_url = hiera('nova::neutron_url', 'http://localhost:9696')
  $cinder_endpoint_template = hiera('nova::cinder_endpoint_template', false)

  include mysql::python
  include memcached::python

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

}
