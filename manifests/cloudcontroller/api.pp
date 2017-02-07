# api node
class nova::cloudcontroller::api(
  $workers          = 2,
  $metadata_workers = 1,
) inherits nova::cloudcontroller {

  $metadata_proxy_shared_secret = hiera(
    'neutron::agents::metadata::shared_secret', false
  )

  File['/etc/nova/nova.conf'] {
    content => template("nova/${::openstack_version}/nova.conf-api.erb"),
  }

}
