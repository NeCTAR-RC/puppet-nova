class oldnova::scheduler {

  require oldnova::cloudcontroller

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

  $procs = $::processorcount + 1

  nagios::nrpe::service {
    'service_nova_scheduler':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${procs}:${procs} -u nova -a /usr/bin/nova-scheduler";
  }
}
