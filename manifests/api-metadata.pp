# Keep backwards compatability. Remove when everyone migrates to the new class
class nova::api-metadata {
    include ::nova::api::metadata
}
