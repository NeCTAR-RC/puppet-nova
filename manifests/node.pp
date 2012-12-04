class nova::node {

  package { 'nova-compute':
    ensure  => present,
    require => User['nova'],
  }

  package { 'nova-network':
    ensure  => present,
    require => User['nova'],
  }

  package {['pm-utils', 'kvm-ipxe']:
    ensure => installed,
  }

  realize Package['python-memcache']
  realize Package['python-mysqldb']

  if $nova_cc_nfs_instances_mount {

    package { 'nfs-common':
      ensure => installed,
    }

    mount { '/var/lib/nova/instances':
      device  => $nova_cc_nfs_instances_mount,
      fstype  => 'nfs',
      ensure  => mounted,
      options => $nfs_options,
      atboot  => true,
      require => [ Package['nova-compute'],
                   Package['nfs-common']],
    }
  }
  group { 'nova':
    ensure => present,
  }

  user { 'nova':
    ensure     => present,
    uid        => 118,
    gid        => nova,
    groups     => ['libvirtd'],
    shell      => '/bin/bash',
    home       => '/var/lib/nova',
    managehome => false,
    require    => [ Package['libvirt-bin'],
                    Group['nova']],
  }

  file { '/etc/nova/nova.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    require => Package['nova-compute'],
    content => template("nova/nova.conf.compute-${openstack_version}.erb"),
  }

  file { '/etc/nova/nova-compute.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0640',
    require => Package['nova-compute'],
    content => template("nova/nova-compute.conf-${openstack_version}.erb"),
  }

  file { '/etc/nova/dnsmasq.conf':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0644',
    require => Package['nova-compute'],
    content => template('nova/dnsmasq.conf.erb'),
  }

  service { 'nova-compute':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe => [ File['/etc/nova/nova-compute.conf'],
                   File['/etc/nova/nova.conf']],
  }

  service { 'nova-network':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe => File['/etc/nova/nova.conf'],
  }

  include nova::kvm
  include nova::libvirt

  nagios::nrpe::service {
    'service_nova_compute':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-compute';
    'service_nova_network':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-network';
    'service_dnsmasq':  # RE is used to prevent check_procs matching its self.
      check_command => '/usr/lib/nagios/plugins/check_procs -c 2:2 --ereg-argument-array /usr/sbin/dnsmas[q]';
  }

  file { '/etc/nova/api-paste.ini':
    ensure  => present,
    owner   => nova,
    group   => nova,
    mode    => '0600',
    content => template("nova/api-paste.ini-${openstack_version}.erb"),
    notify  => Service['nova-api-metadata'],
    require => Package['nova-api-metadata'],
  }


  package { 'nova-api-metadata':
    ensure  => present,
    require => User['nova'],
  }

  service { 'nova-api-metadata':
    ensure    => running,
    enable    => true,
    provider  => upstart,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-api-metadata'],
  }

  nagios::nrpe::service {
    'service_nova_api_metadata':
      check_command => '/usr/lib/nagios/plugins/check_procs -c 1:1 -u nova -a /usr/bin/nova-api-metadata';
  }
}
