class nova::conductor($workers=0) {

  require nova::cloudcontroller
  $openstack_version = hiera('openstack_version')

  package { 'nova-conductor':
    ensure => present,
    tag    => 'openstack',
  }

  service { 'nova-conductor':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-conductor'],
  }
  if $workers == 0 {
    $cores = $::processorcount + 1
  } else {
    $cores = $workers
  }
  nagios::nrpe::service {
    'service_nova_conductor':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${cores}:${cores} -u nova -a /usr/bin/nova-conductor";
  }
}
