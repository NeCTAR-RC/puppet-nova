class nova::cloudcontroller {

  realize Package['python-mysqldb']
  realize Package['python-keystone']

  package {'nova-common':
    ensure => installed,
  }

  file { '/etc/nova/nova.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    content => template("nova/novacloudcontroller.conf-${openstack_version}.erb"),
    require => Package['nova-common'],
  }

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    content => template("nova/api-paste.ini-${openstack_version}.erb"),
    require => Package['nova-common'],
  }

}
