# == definition fluentd::configfile
define fluentd::configfile(
  $ensure   = present,
  $content,
  $priority = 50,
) {
  $base_name     = "${name}.conf"
  $conf_name     = "${priority}-${base_name}"
  $conf_path     = "/etc/td-agent/config.d/${conf_name}"
  $wildcard_path = "/etc/td-agent/config.d/*-${base_name}"

  if $ensure == 'absent' {
    file { $conf_path:
      ensure  => $ensure,
      notify  => Class['fluentd::service'],
    }
  } else {
    file { $conf_path:
      ensure  => $ensure,
      content => $content,
      owner   => 'td-agent',
      group   => 'td-agent',
      mode    => '0644',
      require => Class['fluentd::packages'],
      notify  => Class['fluentd::service'],
    }
  }
}
