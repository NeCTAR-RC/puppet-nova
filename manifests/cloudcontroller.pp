class nova::cloudcontroller($extra_config={}) {

  require nova

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')
  $use_conductor = hiera('nova::use_conductor', false)
  $icehouse_compat = hiera('nova::icehouse_compat', false)

  include mysql::python
  realize Package['python-keystone']

  package {'nova-common':
    ensure => installed,
  }

  file { '/etc/nova/nova.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    content => template("nova/${openstack_version}/nova.conf-cell.erb"),
    require => Package['nova-common'],
  }

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    content => template("nova/${openstack_version}/api-paste.ini.erb"),
    require => Package['nova-common'],
  }

  file { '/etc/nova/policy.json':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    source  => "puppet:///modules/nova/${openstack_version}/policy.json",
    require => Package['nova-common'],
  }

}

class nova::cloudcontroller::api($workers=2) inherits nova::cloudcontroller {

  File['/etc/nova/nova.conf'] {
    content => template("nova/${openstack_version}/nova.conf-api.erb"),
  }

}
