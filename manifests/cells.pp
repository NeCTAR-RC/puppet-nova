class nova::cells {

  package { 'nova-cells':
    ensure  => installed,
  }

  service { 'nova-cells':
    ensure    => running,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-cells'],
  }

  nagios::nrpe::service {
    'service_nova_cells':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-cells';
  }
}
