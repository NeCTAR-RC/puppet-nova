class nova::spiceproxy {

  require nova::cloudcontroller

  package { 'nova-spiceproxy':
    ensure => installed,
  }

  service { 'nova-spiceproxy':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
  }

  nagios::nrpe::service {
    'service_nova_spiceproxy':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:20 -w 1:10 -u nova -a /usr/bin/nova-spicehtml5proxy';
  }

  nagios::service {
    'http_spiceproxy':
      check_command => 'http_port!6082';
  }

  firewall { '100 spiceproxy':
    dport  => 6082,
    proto  => tcp,
    action => accept,
  }
}
