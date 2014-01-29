class nova::network($gateway, $dns_server_list) {

  require nova::node

  package { 'nova-network':
    ensure  => present,
    require => User['nova'],
  }

  file { '/etc/nova/dnsmasq.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0644',
    require => Package['nova-compute'],
    content => template('nova/dnsmasq.conf.erb'),
  }

  service { 'nova-network':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe => File['/etc/nova/nova.conf'],
  }

  nagios::nrpe::service {
    'service_nova_network':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-network';
    'service_dnsmasq':  # RE is used to prevent check_procs matching its self.
    check_command => '/usr/lib/nagios/plugins/check_procs -c 2:2 --ereg-argument-array /usr/sbin/dnsmas[q]';
  }

}
