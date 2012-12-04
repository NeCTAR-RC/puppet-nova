class nova::volume {

  package { 'nova-volume':
    ensure => installed,
  }

  service { 'nova-volume':
    ensure  => running,
    require => Package['nova-volume'],
  }
}
