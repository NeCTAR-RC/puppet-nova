class nova::cloudcontroller {

  $cell_config = hiera_hash('nova::cell_config')

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
    content => template("nova/nova.conf-cell-${openstack_version}.erb"),
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

class nova::cloudcontroller::api inherits nova::cloudcontroller {

  File['/etc/nova/nova.conf'] {
    content => template("nova/nova.conf-api-${openstack_version}.erb"),
  }

}
