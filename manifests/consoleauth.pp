class nova::consoleauth (
  enabled = true,
){

  require nova::cloudcontroller

  package { 'nova-consoleauth':
    ensure => installed,
  }

  $service_ensure = $enabled ? {
    true  => 'running',
    false => 'stopped',
  }

  service { 'nova-consoleauth':
    ensure    => $service_ensure,
    enable    => $enabled,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-consoleauth'],
  }

  nagios::nrpe::service {
    'service_nova_consoleauth':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-consoleauth';
  }
}
