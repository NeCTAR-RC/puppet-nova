class nova::api {

  require nova::cloudcontroller::api

  package { 'nova-api':
    ensure  => present,
  }

  service { 'nova-api':
    ensure     => running,
    enable     => true,
    subscribe  => [ File['/etc/nova/nova.conf'],
                    File['/etc/nova/api-paste.ini']],
  }

  nagios::service {
    'http_nova-api':
      check_command => 'http_port!8774',
      servicegroups => 'openstack-endpoints';
  }
  $procs = ($nova::cloudcontroller::api::workers * 2) + 1

  nagios::nrpe::service {
    'service_nova_api':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${procs}:${procs} -u nova -a /usr/bin/nova-api";
  }

  firewall { '100 nova-api and ec2':
    dport   => [8773, 8774],
    proto  => tcp,
    action => accept,
  }

}

