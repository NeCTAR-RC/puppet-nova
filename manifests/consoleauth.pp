class nova::consoleauth {

  require nova::cloudcontroller

  package { 'nova-consoleauth':
    ensure => installed,
  }

  service { 'nova-consoleauth':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-consoleauth'],
  }

  include memcached::python

  nagios::nrpe::service {
    'service_nova_consoleauth':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-consoleauth';
  }
}
