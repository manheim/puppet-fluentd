# == class fluentd::packages
class fluentd::packages (
    $package_name = $fluentd::package_name,
    $install_repo = $fluentd::install_repo,
    $package_ensure = $fluentd::package_ensure,
    $version = $fluentd::version
){
    include fluentd::params

    if $install_repo {
        case $::osfamily {
            'redhat': {
                class{'fluentd::install_repo::yum':
                    version => $version,
                    before  => Package[$package_name],
                }
            }
            'debian': {
                class{'fluentd::install_repo::apt':
                    version => $version,
                    before => Package[$package_name],
                }
            }
            default: {
                fail("Unsupported osfamily ${::osfamily}")
            }
        }
    }

    package { "$package_name":
        ensure => $package_ensure
    }

    # safely convert to integer
    if ($::operatingsystemmajrelease == '' or $::operatingsystemmajrelease == undef) {
      $majver = 0
    } else {
      $majver = 0 + $::operatingsystemmajrelease
    }

    if ($::osfamily == 'RedHat' and $majver >= 7) {
      # this is a workaround for https://github.com/treasure-data/td-agent/pull/82
      # and https://github.com/treasure-data/td-agent/issues/87 where the td-agent
      # RPMs do not yet have a systemd unit file.

      file {'/etc/rc.d/init.d/td-agent':
        ensure => absent,
        require => Package[$package_name],
      }

      file { 'td-agent.service':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        path    => '/etc/systemd/system/td-agent.service',
        source  => 'puppet:///modules/fluentd/td-agent.service',
        notify  => Exec['td-agent-systemd-reload'],
        require => File['/etc/rc.d/init.d/td-agent'],
      }

      exec {'td-agent-systemd-reload':
        command     => '/usr/bin/systemctl daemon-reload',
        user        => 'root',
        refreshonly => true,
        require     => File['td-agent.service'],
        before      => Service[$fluentd::params::service_name],
      }
    }

    # extra bits... why this is required isn't quite clear.
    case $::osfamily {
        'debian': {
            package{[
                'libxslt1.1',
                'libyaml-0-2',
            ]:
                before => Package[$package_name],
                ensure => $package_ensure
            }
            exec {'add user td-agent to group adm':
                provider => shell,
                unless => '/bin/grep -q "adm\S*td-agent" /etc/group',
                command => '/usr/sbin/usermod -aG adm td-agent',
                subscribe => Package[$package_name],
            }
        }
        default: {
            info("No required fluentd::packages extra bits for ${::osfamily}")
        }
    }

}
