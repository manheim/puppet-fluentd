##apt.pp

# Class: fluentd::install_repo::apt ()
#
#
class fluentd::install_repo::apt (
    $version = $fluentd::params::version
) {

    if ($version == '1') {
        $baseurl = 'http://packages.treasuredata.com/debian'
    } else {
        $baseurl = "http://packages.treasuredata.com/${version}/debian"
    }

    apt::source { 'treasure-data':
        location    => $baseurl,
        release     => "lucid",
        repos       => "contrib",
        include_src => false,
    }

    file { '/tmp/packages.treasure-data.com.key':
        ensure => file,
        source => 'puppet:///modules/fluentd/packages.treasure-data.com.key'
    }->
    exec { "import gpg key Treasure Data":
        command => "/bin/cat /tmp/packages.treasure-data.com.key | apt-key add -",
        unless  => "/usr/bin/apt-key list | grep -q 'Treasure Data'",
        notify  => Class['::apt::update'],
    }
}
