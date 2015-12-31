# yum.pp 

# Class: fluentd::install_repo::yum ()
#
#
class fluentd::install_repo::yum (
    $version = $fluentd::params::version,
    $key     = $fluentd::params::yum_key_url,
) {

    # Sorry for the different naming of the Repository between debian and redhat.
    # But I dont want rename it to avoid a duplication.

    if ($version == '1') {
        $baseurl = 'http://packages.treasuredata.com/redhat/$basearch'
    } else {
        $baseurl = "http://packages.treasuredata.com/${version}/redhat/\$releasever/\$basearch"
    }

    yumrepo { 'treasuredata':
        descr => 'Treasure Data',
        baseurl => $baseurl,
        gpgkey => 'http://packages.treasuredata.com/redhat/RPM-GPG-KEY-td-agent',
        gpgcheck => 1,
    }

}
