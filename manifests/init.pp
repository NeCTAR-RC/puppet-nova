class nova {

  require nectar

  nag::unused_variable{'nova::use_conductor':}
  nag::unused_variable{'nova::cell_type':}
  nag::unused_variable{'nova::cell_name':}
  $unused_cell_variables = ['nova::cell_config.use_cells',
                            'nova::cell_config.cells_instance_updated_at_threshold',
                            'nova::cell_config.cells_instance_update_num_instances',
                            'nova::cell_config.cells_capabilities',
                            'nova::cell_config.cells_expire_reservations',
                            'nova::cell_config.cells_scheduler_direct_only_cells',
                            'nova::cell_config.cells_heal_update_number',
                            'nova::cell_config.capacity_aggregate_key',
                            'nova::cell_config.reserve_percent',
                            'nova::cell_config.free_disk_units_needed',
                            'nova::cell_config.cells_enable',
                            ]
  nag::unused_variable{$unused_cell_variables:
    merge_strategy => 'deep',
  }

}
