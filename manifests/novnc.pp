class nova::novnc {

  require nova::cloudcontroller

  package { 'nova-novncproxy':
    ensure => installed,
  }

  service { 'nova-novncproxy':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['novnc'],
  }

  package { 'novnc':
    ensure => installed,
  }

  nagios::nrpe::service {
    'service_nova_novncproxy':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:20 -w 1:10 -u nova -a /usr/bin/nova-novncproxy';
  }

  nagios::service {
    'http_novncproxy':
      check_command => 'check_novnc!6080';
  }

  firewall { '100 novnc':
    dport  => 6080,
    proto  => tcp,
    action => accept,
  }
}
