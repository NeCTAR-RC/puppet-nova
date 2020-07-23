class oldnova::api {
  $openstack_version = hiera('openstack_version')

  require oldnova::cloudcontroller::api

  package { 'nova-api':
    ensure => present,
    tag    => 'openstack',
  }

  service { 'nova-api':
    ensure     => running,
    enable     => true,
    subscribe  => [ File['/etc/nova/nova.conf'],
                    File['/etc/nova/api-paste.ini']],
  }

}
