class nova::api {
  $openstack_version = hiera('openstack_version')

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

  # ec2api removed from nova in mitaka
  if ($openstack_version == 'kilo' or
      $openstack_version == 'liberty') {
    nagios::service {
      'http_ec2':
        check_command => 'check_ec2!8773',
        servicegroups => 'openstack-endpoints';
    }
  }
  nagios::service {
    'http_nova-api':
      check_command => 'http_port!8774',
      servicegroups => 'openstack-endpoints';
  }

  # remove after nova-api has been upgraded to mitaka
  if $openstack_version == 'liberty' {
    # liberty has same amount of osapi_compute and ec2 workers, so * 2
    $procs = ($nova::cloudcontroller::api::workers * 2) + 1
  }
  else {
    # mitaka has only osapi_compute workers
    $procs = $nova::cloudcontroller::api::workers + 1
  }

  nagios::nrpe::service {
    'service_nova_api':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${procs}:${procs} -u nova -a /usr/bin/nova-api";
  }

  firewall { '100 nova-api and ec2 and metadata':
    dport  => [8773, 8774, 8775],
    proto  => tcp,
    action => accept,
  }
}
