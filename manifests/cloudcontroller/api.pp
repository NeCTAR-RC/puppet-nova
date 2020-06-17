# api node
class nova::cloudcontroller::api(
  $log_file         = undef,
  $workers          = 2,
  $metadata_workers = 1,
) inherits nova::cloudcontroller {

  $openstack_version = hiera('openstack_version')
  $metadata_proxy_shared_secret = hiera(
    'neutron::agents::metadata::shared_secret', false
  )
  $query_placement_for_availability_zone = hiera(
    'nova::scheduler::query_placement_for_availability_zone', false)

  File['/etc/nova/nova.conf'] {
    content => template("nova/${openstack_version}/nova.conf-api.erb"),
  }

}
