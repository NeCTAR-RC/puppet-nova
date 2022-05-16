# Class nova::compute::vgpu
#
# DEPRECATED !!
# Configures nova compute vgpu options
#
# === Parameters:
#
# [*vgpu_types_device_addresses_mapping*]
#   (optional) Map of vgpu type(s) the instances can get as key and list of
#   corresponding device addresses as value.
#   Defaults to undef
#
class nova::compute::vgpu(
  $vgpu_types_device_addresses_mapping = undef,
) {
  include nova::deps

  include nova::compute::mdev

  if !empty($vgpu_types_device_addresses_mapping) {
    validate_legacy(Hash, 'validate_hash', $vgpu_types_device_addresses_mapping)
    $vgpu_types_real = keys($vgpu_types_device_addresses_mapping)
    nova_config {
      'devices/enabled_vgpu_types': value => join(any2array($vgpu_types_real), ',');
    }
  }
}
