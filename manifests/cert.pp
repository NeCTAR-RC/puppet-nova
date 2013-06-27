class nova::cert {

  require nova::cloudcontroller

  package { 'nova-cert':
    ensure  => installed,
  }

  file { '/var/lib/nova/CA/openssl.cnf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0644',
    source  => 'puppet:///modules/nova/openssl.cnf',
    notify  => Service['nova-cert'],
  }

  service { 'nova-cert':
    ensure  => running,
    require => Package['nova-cert'],
  }

  nagios::nrpe::service {
    'service_nova_cert':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-cert';
  }
}
