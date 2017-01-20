# Class: fluentd::config()
#
#
class fluentd::config (
  $purge_config = $fluentd::purge_config,
  $purge_ignore = $fluentd::purge_ignore,

) {
    file { '/etc/td-agent/td-agent.conf' :
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        content => template('fluentd/td-agent.conf.erb'),
        notify  => Class['fluentd::service'],
    }

    file {'/etc/td-agent/config.d':
        ensure  => 'directory',
        owner   => 'td-agent',
        group   => 'td-agent',
        mode    => '0750',
        recurse => $purge_config,
        purge   => $purge_config,
        ignore  => $purge_ignore,
    }
}
