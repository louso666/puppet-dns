require 'spec_helper'

describe 'dns::server::config', type: :class do
  context 'on an unsupported OS' do
    let :facts do { osfamily: 'Solaris', concat_basedir: '/dne' } end

    it { is_expected.to raise_error(%r{dns::server is incompatible with this osfamily}) }
  end

  context 'on a Debian OS' do
    let (:facts) do
      {
        osfamily: 'Debian',
        operatingsystemrelease: '6',
        concat_basedir: '/dne',
      }
    end

    it { is_expected.to contain_file('/etc/bind/').with_owner('bind') }
    it { is_expected.to contain_file('/etc/bind/named.conf').with_content(/^include "\/etc\/bind\/named.conf.options";$/) }
  end

  context 'on a RedHat OS' do
    let (:facts) do
      {
        osfamily: 'RedHat',
        concat_basedir: '/dne',
      }
    end

    it { is_expected.to contain_file('/etc/named.conf').with_owner('named') }
    it { is_expected.to contain_file('/etc/named.conf').with_content(/^include "\/etc\/named\/named.conf.options";$/) }
  end

  context 'on a RedHat OS with dynamic includes' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        concat_basedir: '/dne',
      }
    end

    let(:params) do
      {
        manage_dynamic_includes: true,
      }
    end

    it do
      is_expected.to contain_file('/etc/named.conf')
        .with_content(%r{include "/etc/named/zones.d/dynamic-keys.conf";})
    end

    it do
      is_expected.to contain_file('/etc/named.conf')
        .with_content(%r{include "/etc/named/zones.d/dynamic-zones.conf";})
    end
  end
end
