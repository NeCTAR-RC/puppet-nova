class oldnova::novnc {

  require oldnova::cloudcontroller

  package { 'nova-novncproxy':
    ensure => installed,
    tag    => 'openstack',
  }

  service { 'nova-novncproxy':
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['novnc'],
  }

  package { 'novnc':
    ensure => installed,
  }

  firewall { '100 novnc':
    dport  => 6080,
    proto  => tcp,
    action => accept,
  }
}
