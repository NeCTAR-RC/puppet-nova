class nova::scheduler {

  require nova::cloudcontroller

  package { 'nova-scheduler':
    ensure => present,
    tag    => 'openstack',
  }

  service { 'nova-scheduler':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-scheduler'],
  }

  nagios::nrpe::service {
    'service_nova_scheduler':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-scheduler';
  }
}
