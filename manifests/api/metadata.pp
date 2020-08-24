#class to manage nova metadata service

class nova::api::metadata {

  package { 'nova-api-metadata':
    ensure  => present,
    require => Package['nova-common'],
  }

  service { 'nova-api-metadata':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-api-metadata'],
  }

}
