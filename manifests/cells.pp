class nova::cells (
  $workers=1,
) {

  require nova::cloudcontroller

  package { 'nova-cells':
    ensure  => installed,
  }

  service { 'nova-cells':
    ensure    => running,
    subscribe => File['/etc/nova/nova.conf'],
    require   => Package['nova-cells'],
  }

  nagios::nrpe::service {
    'service_nova_cells':
      check_command => "/usr/lib/nagios/plugins/check_procs -c $workers:$workers -u nova -a /usr/bin/nova-cells";
  }

  define worker() {
    file {"/etc/init/${name}.conf":
      content => template('nova/nova-cells-init.conf.erb'),
    }

    service {"${name}":
      ensure    => running,
      provider  => upstart,
      subscribe => File['/etc/nova/nova.conf'],
      require   => [File["/etc/init/${name}.conf"], Package['nova-cells']],
    }
  }

  if $workers > 1 {
    $workers_array = range("nova-cells-1", "nova-cells-$workers")
    worker { [$workers_array]: }
  }
}
