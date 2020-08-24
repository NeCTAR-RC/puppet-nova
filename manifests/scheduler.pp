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

}
