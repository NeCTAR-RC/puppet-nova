class oldnova::consoleauth {

  require oldnova::cloudcontroller

  package { 'nova-consoleauth':
    ensure => installed,
  }

  service { 'nova-consoleauth':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-consoleauth'],
  }

}
