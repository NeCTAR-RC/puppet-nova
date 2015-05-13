class nova::api-metadata {

  require nova::node

  $openstack_version = hiera('openstack_version')
  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $cell_config = hiera_hash('nova::cell_config')

  package { 'nova-api-metadata':
    ensure  => present,
    require => User['nova'],
  }

  service { 'nova-api-metadata':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-api-metadata'],
  }

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    content => template("nova/${openstack_version}/api-paste.ini.erb"),
    notify  => Service['nova-api-metadata'],
    require => Package['nova-api-metadata'],
  }
  if $openstack_version == 'icehouse' {
    $workers = $nova::node::metadata_workers + 1
  } else {
    $workers = $nova::node::metadata_workers
  }

  nagios::nrpe::service {
    'service_nova_api_metadata':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${workers}:${workers} -u nova -a /usr/bin/nova-api-metadata";
  }

}
