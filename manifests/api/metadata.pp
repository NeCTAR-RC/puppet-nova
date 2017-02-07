#class to manage nova metadata service

class nova::api::metadata {

  package { 'nova-api-metadata':
    ensure  => present,
    require => Package['nova-common'],
  }

  service { 'nova-api-metadata':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-api-metadata'],
  }

  file { '/etc/nova/rootwrap.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['nova-common'],
  }

  file {'/etc/nova/rootwrap.d/api-metadata.filters':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/nova/rootwrap.d'],
  }

  $workers = $::nova::cloudcontroller::api::workers

  nagios::nrpe::service {
    'service_nova_api_metadata':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${workers}:${workers} -u nova -a /usr/bin/nova-api-metadata";
  }

}