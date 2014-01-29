class nova::api-metadata {

  require nova::node

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

  nagios::nrpe::service {
    'service_nova_api_metadata':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-api-metadata';
  }

}
