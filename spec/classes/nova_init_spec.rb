require 'spec_helper'

describe 'nova' do

  shared_examples 'nova' do

    context 'with default parameters' do

      it 'installs packages' do
        is_expected.to contain_package('python-nova').with(
          :ensure => 'present',
          :tag    => ['openstack', 'nova-package']
        )
        is_expected.to contain_package('nova-common').with(
          :name    => platform_params[:nova_common_package],
          :ensure  => 'present',
          :tag     => ['openstack', 'nova-package']
        )
      end

      it 'configures rootwrap' do
        is_expected.to contain_nova_config('DEFAULT/rootwrap_config').with_value('/etc/nova/rootwrap.conf')
      end

      it { is_expected.to contain_exec('networking-refresh').with(
        :command     => '/sbin/ifdown -a ; /sbin/ifup -a',
        :refreshonly => true
      )}

      it 'does not configure glance api servers' do
        is_expected.to_not contain_nova_config('glance/api_servers')
      end

      it 'does not configure auth_strategy' do
        is_expected.not_to contain_nova_config('api/auth_strategy')
      end

      it 'configures rabbit' do
        is_expected.to contain_nova_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/heartbeat_rate').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/heartbeat_in_pthread').with_value('<SERVICE DEFAULT>')
      end

      it 'configures various things' do
        is_expected.to contain_nova_config('glance/endpoint_override').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('glance/num_retries').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/state_path').with_value('/var/lib/nova')
        is_expected.to contain_nova_config('oslo_concurrency/lock_path').with_value(platform_params[:lock_path])
        is_expected.to contain_nova_config('DEFAULT/service_down_time').with_value('60')
        is_expected.to contain_nova_config('DEFAULT/rootwrap_config').with_value('/etc/nova/rootwrap.conf')
        is_expected.to contain_nova_config('DEFAULT/report_interval').with_value('10')
        is_expected.to contain_nova_config('DEFAULT/ovsdb_connection').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/transport_url').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/rpc_response_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/control_exchange').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('cinder/os_region_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('cinder/cross_az_attach').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('cinder/catalog_info').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/cpu_allocation_ratio').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/ram_allocation_ratio').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/disk_allocation_ratio').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/ssl_only').with_value(false)
        is_expected.to contain_nova_config('DEFAULT/cert').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/key').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('console/ssl_ciphers').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('console/ssl_minimum_version').with_value('<SERVICE DEFAULT>')
      end

      it 'configures block_device_allocate params' do
        is_expected.to contain_nova_config('DEFAULT/block_device_allocate_retries').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('DEFAULT/block_device_allocate_retries_interval').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with overridden parameters' do

      let :params do
        {
          :glance_endpoint_override                => 'http://localhost:9292',
          :glance_num_retries                      => 3,
          :glance_api_servers                      => ['http://localhost:9292', 'http://localhost:9293'],
          :default_transport_url                   => 'rabbit://rabbit_user:password@localhost:5673',
          :rpc_response_timeout                    => '30',
          :control_exchange                        => 'nova',
          :rabbit_heartbeat_timeout_threshold      => '60',
          :rabbit_heartbeat_rate                   => '10',
          :rabbit_heartbeat_in_pthread             => true,
          :lock_path                               => '/var/locky/path',
          :state_path                              => '/var/lib/nova2',
          :service_down_time                       => '120',
          :auth_strategy                           => 'foo',
          :ensure_package                          => '2012.1.1-15.el6',
          :host                                    => 'test-001.example.org',
          :notification_transport_url              => 'rabbit://rabbit_user:password@localhost:5673',
          :notification_driver                     => 'ceilometer.compute.nova_notifier',
          :notification_topics                     => 'openstack',
          :notification_format                     => 'unversioned',
          :report_interval                         => '60',
          :os_region_name                          => 'MyRegion',
          :cross_az_attach                         => 'MyAZ',
          :ovsdb_connection                        => 'tcp:127.0.0.1:6640',
          :upgrade_level_cells                     => '1.0.0',
          :upgrade_level_cert                      => '1.0.0',
          :upgrade_level_compute                   => '1.0.0',
          :upgrade_level_conductor                 => '1.0.0',
          :upgrade_level_console                   => '1.0.0',
          :upgrade_level_intercell                 => '1.0.0',
          :upgrade_level_network                   => '1.0.0',
          :upgrade_level_scheduler                 => '1.0.0',
          :purge_config                            => false,
          :block_device_allocate_retries           => '60',
          :block_device_allocate_retries_interval  => '3',
          :my_ip                                   => '192.0.2.1',
          :ssl_only                                => true,
          :cert                                    => '/etc/ssl/private/snakeoil.pem',
          :key                                     => '/etc/ssl/certs/snakeoil.pem',
          :console_ssl_ciphers                     => 'kEECDH+aECDSA+AES:kEECDH+AES+aRSA:kEDH+aRSA+AES',
          :console_ssl_minimum_version             => 'tlsv1_2',
        }
      end

      it 'installs packages' do
        is_expected.to contain_package('nova-common').with('ensure' => '2012.1.1-15.el6')
        is_expected.to contain_package('python-nova').with('ensure' => '2012.1.1-15.el6')
      end

      it 'passes purge to resource' do
        is_expected.to contain_resources('nova_config').with({
          :purge => false
        })
      end

      it 'configures glance parameters' do
        is_expected.to contain_nova_config('glance/endpoint_override').with_value('http://localhost:9292')
        is_expected.to contain_nova_config('glance/num_retries').with_value(3)
        is_expected.to contain_nova_config('glance/api_servers').with_value(['http://localhost:9292', 'http://localhost:9293'])
      end

      it 'configures auth_strategy' do
        is_expected.to contain_nova_config('api/auth_strategy').with_value('foo')
      end

      it 'configures rabbit' do
        is_expected.to contain_nova_config('DEFAULT/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_nova_config('DEFAULT/rpc_response_timeout').with_value('30')
        is_expected.to contain_nova_config('DEFAULT/control_exchange').with_value('nova')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/heartbeat_timeout_threshold').with_value('60')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/heartbeat_rate').with_value('10')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/heartbeat_in_pthread').with_value(true)
      end

      it 'configures host' do
        is_expected.to contain_nova_config('DEFAULT/host').with_value('test-001.example.org')
      end

      it 'configures my_ip' do
        is_expected.to contain_nova_config('DEFAULT/my_ip').with_value('192.0.2.1')
      end

      it 'configures upgrade_levels' do
        is_expected.to contain_nova_config('upgrade_levels/cells').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/cert').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/compute').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/conductor').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/console').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/intercell').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/network').with_value('1.0.0')
        is_expected.to contain_nova_config('upgrade_levels/scheduler').with_value('1.0.0')
      end

      it 'configures various things' do
        is_expected.to contain_nova_config('DEFAULT/state_path').with_value('/var/lib/nova2')
        is_expected.to contain_nova_config('oslo_concurrency/lock_path').with_value('/var/locky/path')
        is_expected.to contain_nova_config('DEFAULT/service_down_time').with_value('120')
        is_expected.to contain_nova_config('DEFAULT/rpc_response_timeout').with_value('30')
        is_expected.to contain_nova_config('oslo_messaging_notifications/transport_url').with_value('rabbit://rabbit_user:password@localhost:5673')
        is_expected.to contain_nova_config('oslo_messaging_notifications/driver').with_value('ceilometer.compute.nova_notifier')
        is_expected.to contain_nova_config('oslo_messaging_notifications/topics').with_value('openstack')
        is_expected.to contain_nova_config('notifications/notification_format').with_value('unversioned')
        is_expected.to contain_nova_config('DEFAULT/report_interval').with_value('60')
        is_expected.to contain_nova_config('DEFAULT/ovsdb_connection').with_value('tcp:127.0.0.1:6640')
        is_expected.to contain_nova_config('cinder/os_region_name').with_value('MyRegion')
        is_expected.to contain_nova_config('cinder/cross_az_attach').with_value('MyAZ')
        is_expected.to contain_nova_config('DEFAULT/ssl_only').with_value(true)
        is_expected.to contain_nova_config('DEFAULT/cert').with_value('/etc/ssl/private/snakeoil.pem')
        is_expected.to contain_nova_config('DEFAULT/key').with_value('/etc/ssl/certs/snakeoil.pem')
        is_expected.to contain_nova_config('console/ssl_ciphers').with_value('kEECDH+aECDSA+AES:kEECDH+AES+aRSA:kEDH+aRSA+AES')
        is_expected.to contain_nova_config('console/ssl_minimum_version').with_value('tlsv1_2')
      end

      context 'with multiple notification_driver' do
        before { params.merge!( :notification_driver => ['ceilometer.compute.nova_notifier', 'nova.openstack.common.notifier.rpc_notifier']) }

        it { is_expected.to contain_nova_config('oslo_messaging_notifications/driver').with_value(
          ['ceilometer.compute.nova_notifier', 'nova.openstack.common.notifier.rpc_notifier']
        ) }
      end

      it 'configures block_device_allocate params' do
        is_expected.to contain_nova_config('DEFAULT/block_device_allocate_retries').with_value('60')
        is_expected.to contain_nova_config('DEFAULT/block_device_allocate_retries_interval').with_value('3')
      end
    end

    context 'with wrong notify_on_state_change parameter' do
      let :params do
        { :notify_on_state_change => 'vm_status' }
      end

      it 'configures database' do
        is_expected.to contain_nova_config('notifications/notify_on_state_change').with_ensure('absent')
      end
    end

    context 'with notify_on_state_change parameter' do
      let :params do
        { :notify_on_state_change => 'vm_state' }
      end

      it 'configures database' do
        is_expected.to contain_nova_config('notifications/notify_on_state_change').with_value('vm_state')
      end
    end

    context 'with kombu_reconnect_delay set to 5.0' do
      let :params do
        { :kombu_reconnect_delay => '5.0' }
      end

      it 'configures rabbit' do
        is_expected.to contain_nova_config('oslo_messaging_rabbit/kombu_reconnect_delay').with_value('5.0')
      end
    end

    context 'with rabbit_ha_queues set to true' do
      let :params do
        { :rabbit_ha_queues => true }
      end

      it 'configures rabbit' do
        is_expected.to contain_nova_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(true)
      end
    end

    context 'with rabbit_ha_queues set to false' do
      let :params do
        { :rabbit_ha_queues => false }
      end

      it 'configures rabbit' do
        is_expected.to contain_nova_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value(false)
      end
    end

    context 'with amqp_durable_queues parameter' do
      let :params do
        { :amqp_durable_queues => true }
      end

      it 'configures rabbit' do
        is_expected.to contain_nova_config('oslo_messaging_rabbit/rabbit_ha_queues').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_rabbit/amqp_durable_queues').with_value(true)
        is_expected.to contain_oslo__messaging__rabbit('nova_config').with(
          :rabbit_use_ssl => '<SERVICE DEFAULT>',
        )
      end
    end

    context 'with rabbit ssl enabled with kombu' do
      let :params do
        { :rabbit_use_ssl     => true,
          :kombu_ssl_ca_certs => '/etc/ca.cert',
          :kombu_ssl_certfile => '/etc/certfile',
          :kombu_ssl_keyfile  => '/etc/key',
          :kombu_ssl_version  => 'TLSv1', }
      end

      it { is_expected.to contain_oslo__messaging__rabbit('nova_config').with(
        :rabbit_use_ssl     => true,
        :kombu_ssl_ca_certs => '/etc/ca.cert',
        :kombu_ssl_certfile => '/etc/certfile',
        :kombu_ssl_keyfile  => '/etc/key',
        :kombu_ssl_version  => 'TLSv1'
      )}
    end

    context 'with rabbit ssl enabled without kombu' do
      let :params do
        { :rabbit_use_ssl => true, }
      end

      it { is_expected.to contain_oslo__messaging__rabbit('nova_config').with(
        :rabbit_use_ssl => true,
      )}
    end

    context 'with amqp default parameters' do
      it 'configures amqp' do
        is_expected.to contain_nova_config('oslo_messaging_amqp/server_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/broadcast_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/group_request_prefix').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/container_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/idle_timeout').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/trace').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_ca_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_cert_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_key_file').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_key_password').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/allow_insecure_clients').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/sasl_mechanisms').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/sasl_config_dir').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/sasl_config_name').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/username').with_value('<SERVICE DEFAULT>')
        is_expected.to contain_nova_config('oslo_messaging_amqp/password').with_value('<SERVICE DEFAULT>')
      end
    end

    context 'with amqp overridden parameters' do
      let :params do
        { :amqp_idle_timeout  => '60',
          :amqp_trace         => true,
          :amqp_ssl_ca_file   => '/etc/ca.cert',
          :amqp_ssl_cert_file => '/etc/certfile',
          :amqp_ssl_key_file  => '/etc/key',
          :amqp_username      => 'amqp_user',
          :amqp_password      => 'password',
        }
      end

      it 'configures amqp overide' do
        is_expected.to contain_nova_config('oslo_messaging_amqp/idle_timeout').with_value('60')
        is_expected.to contain_nova_config('oslo_messaging_amqp/trace').with_value('true')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_ca_file').with_value('/etc/ca.cert')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_cert_file').with_value('/etc/certfile')
        is_expected.to contain_nova_config('oslo_messaging_amqp/ssl_key_file').with_value('/etc/key')
        is_expected.to contain_nova_config('oslo_messaging_amqp/username').with_value('amqp_user')
        is_expected.to contain_nova_config('oslo_messaging_amqp/password').with_value('password')
      end
    end

    context 'with ssh public key' do
      let :params do
        {
          :nova_public_key => {'type' => 'ssh-rsa',
                               'key'  => 'keydata'}
        }
      end

      it 'should install ssh public key' do
        is_expected.to contain_ssh_authorized_key('nova-migration-public-key').with(
          :ensure => 'present',
          :key => 'keydata',
          :type => 'ssh-rsa'
        )
      end
    end

    context 'with ssh public key missing key type' do
      let :params do
        {
          :nova_public_key => {'key'  => 'keydata'}
        }
      end

      it 'should raise an error' do
        expect {
          is_expected.to contain_ssh_authorized_key('nova-migration-public-key').with(
            :ensure => 'present',
            :key => 'keydata'
          )
        }.to raise_error Puppet::Error, /You must provide both a key type and key data./
      end
    end

    context 'with ssh public key missing key data' do
      let :params do
        {
          :nova_public_key => {'type' => 'ssh-rsa'}
        }
      end

      it 'should raise an error' do
        expect {
          is_expected.to contain_ssh_authorized_key('nova-migration-public-key').with(
            :ensure => 'present',
            :key => 'keydata'
          )
        }.to raise_error Puppet::Error, /You must provide both a key type and key data./
      end
    end

    context 'with ssh private key' do
      let :params do
        {
          :nova_private_key => {'type' => 'ssh-rsa',
                                'key'  => 'keydata'}
        }
      end

      it 'should install ssh private key' do
        is_expected.to contain_file('/var/lib/nova/.ssh/id_rsa').with(
          :content => 'keydata'
        )
      end
    end

    context 'with ssh private key missing key type' do
      let :params do
        {
          :nova_private_key => {'key'  => 'keydata'}
        }
      end

      it 'should raise an error' do
        expect {
          is_expected.to contain_file('/var/lib/nova/.ssh/id_rsa').with(
            :content => 'keydata'
          )
        }.to raise_error Puppet::Error, /You must provide both a key type and key data./
      end
    end

    context 'with ssh private key having incorrect key type' do
      let :params do
        {
          :nova_private_key => {'type' => 'invalid',
                                'key'  => 'keydata'}
        }
      end

      it 'should raise an error' do
        expect {
          is_expected.to contain_file('/var/lib/nova/.ssh/id_rsa').with(
            :content => 'keydata'
          )
        }.to raise_error Puppet::Error, /Unable to determine name of private key file./
      end
    end

    context 'with ssh private key missing key data' do
      let :params do
        {
          :nova_private_key => {'type' => 'ssh-rsa'}
        }
      end

      it 'should raise an error' do
        expect {
          is_expected.to contain_file('/var/lib/nova/.ssh/id_rsa').with(
            :content => 'keydata'
          )
        }.to raise_error Puppet::Error, /You must provide both a key type and key data./
      end
    end

    context 'with SSL socket options set' do
      let :params do
        {
          :use_ssl          => true,
          :enabled_ssl_apis => ['osapi_compute'],
          :cert_file        => '/path/to/cert',
          :ca_file          => '/path/to/ca',
          :key_file         => '/path/to/key',
        }
      end

      it { is_expected.to contain_nova_config('DEFAULT/enabled_ssl_apis').with_value('osapi_compute') }
      it { is_expected.to contain_nova_config('ssl/ca_file').with_value('/path/to/ca') }
      it { is_expected.to contain_nova_config('ssl/cert_file').with_value('/path/to/cert') }
      it { is_expected.to contain_nova_config('ssl/key_file').with_value('/path/to/key') }
      it { is_expected.to contain_nova_config('wsgi/ssl_ca_file').with_value('/path/to/ca') }
      it { is_expected.to contain_nova_config('wsgi/ssl_cert_file').with_value('/path/to/cert') }
      it { is_expected.to contain_nova_config('wsgi/ssl_key_file').with_value('/path/to/key') }
    end

    context 'with SSL socket options set with wrong parameters' do
      let :params do
        {
          :use_ssl          => true,
          :enabled_ssl_apis => ['osapi_compute'],
          :ca_file          => '/path/to/ca',
          :key_file         => '/path/to/key',
        }
      end

      it_raises 'a Puppet::Error', /The cert_file parameter is required when use_ssl is set to true/
    end

    context 'with SSL socket options set to false' do
      let :params do
        {
          :use_ssl          => false,
          :enabled_ssl_apis => [],
          :cert_file        => false,
          :ca_file          => false,
          :key_file         => false,
        }
      end

      it { is_expected.to contain_nova_config('DEFAULT/enabled_ssl_apis').with_ensure('absent') }
      it { is_expected.to contain_nova_config('ssl/ca_file').with_ensure('absent') }
      it { is_expected.to contain_nova_config('ssl/cert_file').with_ensure('absent') }
      it { is_expected.to contain_nova_config('ssl/key_file').with_ensure('absent') }
    end

    context 'with allocation ratios set' do
      let :params do
        {
          :cpu_allocation_ratio  => 32.0,
          :ram_allocation_ratio  => 2.0,
          :disk_allocation_ratio => 1.5,
        }
      end

      it { is_expected.to contain_nova_config('DEFAULT/cpu_allocation_ratio').with_value('32.0') }
      it { is_expected.to contain_nova_config('DEFAULT/ram_allocation_ratio').with_value('2.0') }
      it { is_expected.to contain_nova_config('DEFAULT/disk_allocation_ratio').with_value('1.5') }
    end

  end


  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      case facts[:osfamily]
      when 'Debian'
        let (:platform_params) do
          { :nova_common_package => 'nova-common',
            :lock_path           => '/var/lock/nova' }
        end
      when 'RedHat'
        let (:platform_params) do
          { :nova_common_package => 'openstack-nova-common',
            :lock_path           => '/var/lib/nova/tmp' }
        end
      end

      it_behaves_like 'nova'

    end
  end

end
