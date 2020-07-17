#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Class to serve Nova Placement API service.

# Serving Nova Placement API from apache is the recommended way to go for production
# because of limited performance for concurrent accesses.
#
# == Parameters
#
#   [*servername*]
#     The servername for the virtualhost.
#     Optional. Defaults to $::fqdn
#
#   [*api_port*]
#     The port for Novai Placement API service.
#     Optional. Defaults to 80
#
#   [*bind_host*]
#     The host/ip address Apache will listen on.
#     Optional. Defaults to undef (listen on all ip addresses).
#
#   [*path*]
#     The prefix for the endpoint.
#     Optional. Defaults to '/placement'
#
#   [*ssl*]
#     Use ssl ? (boolean)
#     Optional. Defaults to true
#
#   [*workers*]
#     Number of WSGI workers to spawn.
#     Optional. Defaults to 1
#
#   [*priority*]
#     (optional) The priority for the vhost.
#     Defaults to '10'
#
#   [*threads*]
#     (optional) The number of threads for the vhost.
#     Defaults to $::os_workers
#
#   [*ensure_package*]
#     (optional) Control the ensure parameter for the Nova Placement API package ressource.
#     Defaults to 'present'
#
#   [*ssl_cert*]
#   [*ssl_key*]
#   [*ssl_chain*]
#   [*ssl_ca*]
#   [*ssl_crl_path*]
#   [*ssl_crl*]
#   [*ssl_certs_dir*]
#     apache::vhost ssl parameters.
#     Optional. Default to apache::vhost 'ssl_*' defaults.
#
# == Examples
#
#   include apache
#
#   class { 'nova::wsgi::apache': }
#
class oldnova::wsgi::apache_placement (
  $servername      = $::fqdn,
  $api_port        = 80,
  $bind_host       = undef,
  $path            = '/placement',
  $ssl             = true,
  $workers         = 1,
  $ssl_cert        = undef,
  $ssl_key         = undef,
  $ssl_chain       = undef,
  $ssl_ca          = undef,
  $ssl_crl_path    = undef,
  $ssl_crl         = undef,
  $ssl_certs_dir   = undef,
  $threads         = $::os_workers,
  $priority        = '10',
  $ensure_package  = 'present',
  $access_log_file = false,
) {

  include oldnova::params
  include ::apache
  include ::apache::mod::wsgi
  if $ssl {
    include ::apache::mod::ssl
  }

  oldnova::generic_service { 'placement-api':
    service_name   => false,
    package_name   => $::oldnova::params::placement_package_name,
    ensure_package => $ensure_package,
  }

  file { $::oldnova::params::placement_httpd_config_file:
    ensure  => present,
    content => "#
    # This file has been cleaned by Puppet.
    #
    # OpenStack Nova Placement API configuration has been moved to:
    # - ${priority}-placement_wsgi.conf
    #",
  }
  # Ubuntu requires nova-placement-api to be installed before apache to find wsgi script
  Package<| title == 'nova-placement-api'|>
  -> Package<| title == 'httpd'|>

  Package<| title == 'nova-placement-api' |>
  -> File[$::oldnova::params::placement_httpd_config_file]
  ~> Service['httpd']

  ::openstacklib::wsgi::apache { 'placement_wsgi':
    bind_host           => $bind_host,
    bind_port           => $api_port,
    group               => 'nova',
    path                => $path,
    priority            => $priority,
    servername          => $servername,
    ssl                 => $ssl,
    ssl_ca              => $ssl_ca,
    ssl_cert            => $ssl_cert,
    ssl_certs_dir       => $ssl_certs_dir,
    ssl_chain           => $ssl_chain,
    ssl_crl             => $ssl_crl,
    ssl_crl_path        => $ssl_crl_path,
    ssl_key             => $ssl_key,
    threads             => $threads,
    user                => 'nova',
    workers             => $workers,
    wsgi_daemon_process => 'placement-api',
    wsgi_process_group  => 'placement-api',
    wsgi_script_dir     => $::oldnova::params::nova_wsgi_script_path,
    wsgi_script_file    => 'nova-placement-api',
    wsgi_script_source  => $::oldnova::params::placement_wsgi_script_source,
    access_log_file     => $access_log_file,
  }

}
