class nova::api {

  require nova::cloudcontroller

  package { 'nova-api':
    ensure  => present,
  }

  service { 'nova-api':
    ensure     => running,
    enable     => true,
    provider   => upstart,
    subscribe  => [ File['/etc/nova/nova.conf'],
                    File['/etc/nova/api-paste.ini']],
  }
  
}

class nova::api::nagios-checks {
  # These are checks that can be run by the nagios server.
  nagios::command {
    'check_ec2_ssl':
      check_command => '/usr/lib/nagios/plugins/check_http --ssl -u /services/Cloud/ -p \'$ARG1$\' -e 400 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_ec2':
      check_command => '/usr/lib/nagios/plugins/check_http -u /services/Cloud/ -p \'$ARG1$\' -e 400 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
  }
}

class nova::api::load-balanced($ssl=true, $upstream_osapi, $upstream_ec2) inherits nova::api {


  file { '/etc/init/nova-api.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('nova/nova-api-init.conf.erb'),
    require => Package['nova-api'],
    notify  => Service['nova-api'],
  }

  nagios::service {
    'http_ec2_18773':
      check_command => 'check_ec2!18773';
    'http_openstack_18774':
      check_command => 'http_port!18774';
  }


  file { '/etc/nova/nova-api.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0644',
    source  => 'puppet:///modules/nova/nova-api.conf',
    require => Package['nova-api'],
    notify  => Service['nova-api'],
  }

  include nginx

  nginx::proxy { 'osapi':
    port         => 8774,
    ssl          => $ssl,
    upstreams    => $upstream_osapi,
    nagios_check => false,
  }

  nginx::proxy { 'ec2':
    port         => 8773,
    ssl          => $ssl,
    upstreams    => $upstream_ec2,
    nagios_check => false,
  }

  nagios::service {
    'http_ec2_8773':
      check_command => 'check_ec2_ssl!8773',
      servicegroups => 'openstack-endpoints';
    'http_openstack_8774':
      check_command => 'https_port!8774',
      servicegroups => 'openstack-endpoints';
  }

  nagios::nrpe::service {
    'service_nova_api':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 9:9 -u nova -a /usr/bin/nova-api';
  }

  file { ['/etc/init.d/nova-api-2',
          '/etc/init.d/nova-api-3',
          '/etc/init/nova-api-2.conf',
          '/etc/init/nova-api-3.conf',
          '/etc/nova/nova-api-2.conf',
          '/etc/nova/nova-api-3.conf'
          ]:
    ensure => absent,
  }
}
