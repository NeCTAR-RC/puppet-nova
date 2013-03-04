================================
Puppet Nova module for NeCTAR RC
================================

Variables
=========

This module makes explicit use of hiera, you will need it to use this module.
Classes
=======

nova
----

nova::api
---------
Installs and configures nova-api

nova::api::load-balanced
------------------------
Puts nginx in front of nova-api

Requires the puppet-nginx module

 * nova::api::load-balanced::ssl - Use ssl endpoints (default=true)
 * nova::api::load-balanced::upstream_osapi - list of nova-api servers  eg [nova-api-1:18774,nova-api-2:18774]
 * nova::api::load-balanced::upstream_ec2 - Same as osapi except for ec2 api

nova::cells
-----------
Sets up nova-cells

nova::cert
----------
Sets up nova-cert

nova::cloudcontroller
---------------------
Sets up nova configs for cloud controllers. Needs the nova::config variable

nova::cloudcontroller::api
--------------------------
Installs a slightly different nova.conf for an API server

nova::consoleauth
-----------------
Sets up nova-consoleauth, only one needed per site unless using memcache

nova::kvm
---------
 * nova::kvm::gid

nova::libvirt
-------------
 * nova::libvirt::uid

nova::node
----------
Sets up nova configs for compute nodes. Needs the nova::config variable

This class currently pulls in nova::kvm and nova::libvirt

 * nova::node::nova_uid
 * nova::node::instances_mount - Set this to use NFS for /var/lib/nova/instances

nova::novnc
-----------
Sets up nova-novncproxy

nova::scheduler
---------------
Sets up nova-scheduler


nova::config
============

This is a hash object that is used to configure nova.

If you have multiple cells you will need to specify this multiple times
Example:
--------

```yaml
nova::cell_config:
    rabbit_hosts: 'mq:5671,mq2:5671,mq2:5671'
    rabbit_ha: true
    rabbit_user: nova
    rabbit_pass: secret
    rabbit_durable: true
    rabbit_ssl: true
    rabbit_virtual_host: my-cell-name
    db_host: db1
    db_user: nova
    db_pass: secret
    db_name: nova
    network_size: 256
    dhcp_domain: novalocal
    fixed_ip_range: "192.168.1.0/24"
    flat_network_dns: '8.8.8.8'
    flat_network_dhcp_start: "192.168.1.10"
    flat_interface: 'eth0'
    network_bridge: 'br100'
    keystone_user: nova
    keystone_password: secret     
    glance_servers: 'https://localhost:9292'
    memcached_servers: 'localhost:11211'
    vnc_host: 'localhost'
    cells_enable: true
    cells_name: my-cell-name
    cells_full_name: my-full-cell-name
```

Other variables needed
======================

 * keystone::host
 * keystone::protocol
 * keystone::service_tenant

 * swift::protocol
 * nfs::options
