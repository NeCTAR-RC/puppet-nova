# Keep backwards compatability. Remove when everyone migrates to the new class
class nova::api-metadata {
    include ::nova::api::metadata

    notify {'class nova::api-metadata is deprecated. Please use nova::api::metadata': }
}
