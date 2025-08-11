require 'spec_helper'

describe 'dns' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(concat_basedir: '/dne') }
      let(:params) do
        {
          manage_dynamic_includes: true,
          tsig_keys: {
            'updater' => {
              'algo'   => 'hmac-sha256',
              'secret' => 'supersecret',
            },
          },
          dynamic_zones: {
            'dyn.example.com' => {
              'file'         => '/var/named/dynamic/dyn.example.com',
              'allow_update' => ['key updater'],
              'allow_query'  => ['any'],
            },
          },
        }
      end

      it { is_expected.to contain_file('/etc/named/zones.d/dynamic-keys.conf').with_content(%r{key "updater"}) }
      it { is_expected.to contain_file('/etc/named/zones.d/dynamic-zones.conf').with_content(%r{zone "dyn.example.com"}) }
    end
  end
end
