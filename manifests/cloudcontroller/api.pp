# api node
class oldnova::cloudcontroller::api inherits oldnova::cloudcontroller {

  $log_file = hiera('nova::cloudcontroller::api::log_file')
  $workers = hiera('nova::cloudcontroller::api::workers', 2)
  $metadata_workers = hiera('nova::cloudcontroller::api::metadata_workers', 1)

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
