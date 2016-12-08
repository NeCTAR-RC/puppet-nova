# Keep backwards compatability. Remove when everyone migrates to the new class
class nova::api::nagios-checks {
    include ::nova::api::nagios_checks
}
