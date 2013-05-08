class nova::cloudcontroller {

  require nova

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
    content => template("nova/${openstack_version}/nova.conf-cell.erb"),
    require => Package['nova-common'],
  }

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    content => template("nova/${openstack_version}/api-paste.ini.erb"),
    require => Package['nova-common'],
  }

}

class nova::cloudcontroller::api inherits nova::cloudcontroller {

  File['/etc/nova/nova.conf'] {
    content => template("nova/${openstack_version}/nova.conf-api.erb"),
  }

}
