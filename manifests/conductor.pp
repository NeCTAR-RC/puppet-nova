class nova::conductor {

  require nova::cloudcontroller

  package { 'nova-conductor':
    ensure  => present,
  }

  service { 'nova-conductor':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe =>  File['/etc/nova/nova.conf'],
    require   => Package['nova-conductor'],
  }

  nagios::nrpe::service {
    'service_nova_conductor':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-conductor';
  }
}
