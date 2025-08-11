# == Class dns
#
# Main class for DNS configuration. Optional management of dynamic include
# files for TSIG keys and dynamic zones.
#
class dns (
  String  $dynamic_include_dir  = '/etc/named/zones.d',
  String  $dynamic_keys_file    = 'dynamic-keys.conf',
  String  $dynamic_zones_file   = 'dynamic-zones.conf',
  Hash    $tsig_keys            = {},
  Hash    $dynamic_zones        = {},
  Boolean $manage_dynamic_includes = false,
) {
  include dns::server::params

  if $manage_dynamic_includes {
    file { $dynamic_include_dir:
      ensure => directory,
      owner  => $dns::server::params::owner,
      group  => $dns::server::params::group,
      mode   => '0755',
    }

    file { "${dynamic_include_dir}/${dynamic_keys_file}":
      ensure  => file,
      owner   => $dns::server::params::owner,
      group   => $dns::server::params::group,
      mode    => '0640',
      content => epp('dns/dynamic-keys.epp', {
        'tsig_keys' => $tsig_keys,
      }),
    }

    file { "${dynamic_include_dir}/${dynamic_zones_file}":
      ensure  => file,
      owner   => $dns::server::params::owner,
      group   => $dns::server::params::group,
      mode    => '0640',
      content => epp('dns/dynamic-zones.epp', {
        'dynamic_zones' => $dynamic_zones,
      }),
    }

    file { '/var/named/dynamic':
      ensure => directory,
      owner  => $dns::server::params::owner,
      group  => $dns::server::params::group,
      mode   => '0755',
    }
  }
}
