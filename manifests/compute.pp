class nova::compute {

  require nova::node

  package { 'nova-compute':
    ensure  => present,
    require => User['nova'],
  }

  service { 'nova-compute':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe => [ File['/etc/nova/nova-compute.conf'],
                   File['/etc/nova/nova.conf']],
  }

  file { '/etc/nova/rootwrap.d/compute.filters':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    source  => "puppet:///modules/nova/${openstack_version}/compute.filters",
    require => Package['nova-common'],
  }

  nagios::nrpe::service {
    'service_nova_compute':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-compute';
  }
}
