class oldnova::conductor {

  require oldnova::cloudcontroller
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
}
