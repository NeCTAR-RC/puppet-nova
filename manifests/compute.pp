# Nova compute manifest
class nova::compute {

  require nova::node

  $openstack_version = hiera('openstack_version')

  package { 'nova-compute':
    ensure  => present,
    require => User['nova'],
    tag     => 'openstack',
  }

  # Mitigation for iptables rule ordering issue
  if $openstack_version[0] >= 'n' and $openstack_version[0] < 'q' {

    include ::systemd

    file { '/etc/systemd/system/nova-compute.service.d':
      ensure => directory,
    }
    file { '/etc/systemd/system/nova-compute.service.d/override.conf':
      ensure  => present,
      source  => 'puppet:///modules/nova/nova-compute-service-override.conf',
      require => File['/etc/systemd/system/nova-compute.service.d'],
      } ~> Exec['systemctl-daemon-reload'] ~> Service['nova-compute']
  } else {
    file { '/etc/systemd/system/nova-compute.service.d/override.conf':
      ensure => absent,
      notify => Exec['systemctl-daemon-reload'],
    }
  }

  service { 'nova-compute':
    ensure    => running,
    enable    => true,
    subscribe => [
      File['/etc/nova/nova-compute.conf'],
      File['/etc/nova/nova.conf']
    ],
  }

  nagios::nrpe::service {
    'service_nova_compute':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-compute';
  }

  file {'/var/lib/nova/instances':
    ensure  => directory,
    owner   => nova,
    group   => nova,
    require => Package['nova-common'],
  }

  $instances_mount = hiera('nova::node::instances_mount', undef)

  if $instances_mount {

    package { 'nfs-common':
      ensure => installed,
    }

    mount { '/var/lib/nova/instances':
      ensure  => mounted,
      device  => $instances_mount,
      fstype  => hiera('nfs::type', 'nfs'),
      options => hiera('nfs::options', '_netdev,auto'),
      atboot  => true,
      require => [
        Package['nova-compute'],
        Package['nfs-common'],
      ],
    }
  }
}
