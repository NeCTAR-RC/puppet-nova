# Rootwrap dir
class nova::rootwrap {

  file { '/etc/nova/rootwrap.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['nova-common'],
  }
}
