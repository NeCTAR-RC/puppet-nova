class nova::cert {

  package { 'nova-cert':
    ensure  => installed,
  }

  mount { '/var/lib/nova/CA':
    device  => $nova_cc_nfs_ca_mount,
    fstype  => 'nfs',
    ensure  => mounted,
    options => '_netdev,auto',
    atboot  => true,
    notify  => Service['nova-cert'],
    require => [ Package['nfs-common'],
                 Package['nova-cert']],
  }

  file { '/var/lib/nova/CA/openssl.cnf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0644',
    source  => 'puppet:///modules/nova/openssl.cnf',
    notify  => Service['nova-cert'],
    require => Mount['/var/lib/nova/CA'],
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
