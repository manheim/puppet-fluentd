#!/usr/bin/env rspec
require 'spec_helper'

describe 'fluentd::packages', :type => :class do
  let (:params) {{:package_name => 'td-agent', :package_ensure => 'installed'}}
  context "On a Debian OS" do
    let :facts do
      {
        :osfamily                  => 'Debian',
        :operatingsystemrelease    => '7',
        :operatingsystemmajrelease => '7',
        :lsbdistid                 => 'Debian',
      }
    end

    context "with install_repo=>true and version=>1" do
      let(:params) {{
                      :install_repo => true,
                      :package_name   => 'td-agent',
                      :package_ensure => 'running',
                      :version        => '1',
                    }}
      it do
        should contain_apt__source("treasure-data").with(
          'location'  => 'http://packages.treasuredata.com/debian'
        )
      end
    end

    context "with install_repo=>true and version=>2" do
      let(:params) {{
                      :install_repo => true,
                      :package_name   => 'td-agent',
                      :package_ensure => 'running',
                      :version        => '2',
                    }}
      it do
        should contain_apt__source("treasure-data").with(
          'location'  => 'http://packages.treasuredata.com/2/debian'
        )
      end
    end

    it { should contain_package("libxslt1.1").with(
      'ensure'  => 'installed'
      )
    }
    it { should contain_package("libyaml-0-2").with(
      'ensure'  => 'installed'
      )
    }
    it { should contain_package("td-agent").with(
      'ensure'  => 'installed'
      )
    }

    it { should_not contain_file('/etc/rc.d/init.d/td-agent') }
    it { should_not contain_file('td-agent.service') }
    it { should_not contain_exec('td-agent-systemd-reload') }
  end

  context "On a RedHat/Centos 6 OS" do

    let :params  do
      {
        :package_name => 'td-agent',
        :package_ensure => 'running',
      } 
    end

    let :facts do
      {
        :osfamily                  => 'Redhat',
        :operatingsystemmajrelease => '6',
      }
    end

    it { should contain_class('fluentd::packages')}
    
    context "with install_repo=>true and version=>1" do
      let(:params) {{
                      :install_repo   => true,
                      :package_name   => 'td-agent',
                      :package_ensure => 'running',
                      :version        => '1',
                    }}
      it do
        should contain_yumrepo('treasuredata').with(
          'baseurl'  => 'http://packages.treasuredata.com/redhat/$basearch',
          'gpgkey'   => 'http://packages.treasuredata.com/redhat/RPM-GPG-KEY-td-agent',
          'gpgcheck' => 1
        )
      end
    end

    context "with install_repo=>true and version=>2" do
      let(:params) {{
                      :install_repo   => true,
                      :package_name   => 'td-agent',
                      :package_ensure => 'running',
                      :version        => '2',
                    }}
      it do
        should contain_yumrepo('treasuredata').with(
          'baseurl'  => 'http://packages.treasuredata.com/2/redhat/$releasever/$basearch',
          'gpgkey'   => 'http://packages.treasuredata.com/redhat/RPM-GPG-KEY-td-agent',
          'gpgcheck' => 1
        )
      end
    end

    it { should contain_package("td-agent").with(
      'ensure'  => 'running'
      )
    }

    it { should_not contain_file('/etc/rc.d/init.d/td-agent') }
    it { should_not contain_file('td-agent.service') }
    it { should_not contain_exec('td-agent-systemd-reload') }
  end

  context "On a RedHat/Centos 7 OS" do

    let :params  do
      {
        :package_name => 'td-agent',
        :package_ensure => 'running',
      } 
    end

    let :facts do
      {
        :osfamily                  => 'Redhat',
        :operatingsystemmajrelease => '7',
      }
    end

    it { should contain_class('fluentd::packages')}
    
    context "with install_repo=>true and version=>1" do
      let(:params) {{
                      :install_repo   => true,
                      :package_name   => 'td-agent',
                      :package_ensure => 'running',
                      :version        => '1',
                    }}
      it do
        should contain_yumrepo('treasuredata').with(
          'baseurl'  => 'http://packages.treasuredata.com/redhat/$basearch',
          'gpgkey'   => 'http://packages.treasuredata.com/redhat/RPM-GPG-KEY-td-agent',
          'gpgcheck' => 1
        )
      end
    end

    context "with install_repo=>true and version=>2" do
      let(:params) {{
                      :install_repo   => true,
                      :package_name   => 'td-agent',
                      :package_ensure => 'running',
                      :version        => '2',
                    }}
      it do
        should contain_yumrepo('treasuredata').with(
          'baseurl'  => 'http://packages.treasuredata.com/2/redhat/$releasever/$basearch',
          'gpgkey'   => 'http://packages.treasuredata.com/redhat/RPM-GPG-KEY-td-agent',
          'gpgcheck' => 1
        )
      end
    end

    it { should contain_package("td-agent").with(
      'ensure'  => 'running',
      )
    }

    it { should contain_file('/etc/rc.d/init.d/td-agent').with(
                  {
                    'ensure' => 'absent',
                    'require' => 'Package[td-agent]',
                  })
    }

    it { should contain_file('td-agent.service').with(
                  {
                    'ensure'  => 'present',
                    'owner'   => 'root',
                    'group'   => 'root',
                    'mode'    => '0644',
                    'path'    => '/etc/systemd/system/td-agent.service',
                    'source'  => 'puppet:///modules/fluentd/td-agent.service',
                    'notify'  => 'Exec[td-agent-systemd-reload]',
                    'require' => 'File[/etc/rc.d/init.d/td-agent]',
                  })
    }

    it { should contain_exec('td-agent-systemd-reload').with(
                  {
                    'command'     => '/usr/bin/systemctl daemon-reload',
                    'user'        => 'root',
                    'refreshonly' => true,
                    'require'     => 'File[td-agent.service]',
                    'before'      => 'Service[td-agent]',
                  })
    }
  end
end
