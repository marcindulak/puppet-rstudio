# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  # puppet
  config.vm.define "puppet" do |puppet|
    puppet.vm.box = "puppetlabs/centos-6.6-64-nocm"
    puppet.vm.box_url = 'puppetlabs/centos-6.6-64-nocm'
    puppet.vm.synced_folder ".", "/etc/puppet/modules/rstudio"
    puppet.vm.synced_folder "tests", "/etc/puppet/manifests"
    puppet.vm.network "private_network", ip: "10.0.4.5"
  end
  # rhel6
  config.vm.define "rhel6" do |rhel6|
    rhel6.vm.box = "puppetlabs/centos-6.6-64-nocm"
    rhel6.vm.box_url = 'puppetlabs/centos-6.6-64-nocm'
    rhel6.vm.network "private_network", ip: "10.0.4.10"
    rhel6.vm.network "forwarded_port", guest: 80, host: 8410
  end
  # rhel7
  config.vm.define "rhel7" do |rhel7|
    rhel7.vm.box = "puppetlabs/centos-7.0-64-nocm"
    rhel7.vm.box_url = 'puppetlabs/centos-7.0-64-nocm'
    rhel7.vm.network "private_network", ip: "10.0.4.20"
    rhel7.vm.network "forwarded_port", guest: 80, host: 8420
  end
  # ubuntu
  config.vm.define "ubuntu14" do |ubuntu14|
    ubuntu14.vm.box = "puppetlabs/ubuntu-14.04-64-nocm"
    ubuntu14.vm.box_url = 'puppetlabs/ubuntu-14.04-64-nocm'
    ubuntu14.vm.network "private_network", ip: "10.0.4.30"
    ubuntu14.vm.network "forwarded_port", guest: 80, host: 8430
  end
  # debian 7.8
  config.vm.define "debian78" do |debian78|
    debian78.vm.box = "puppetlabs/debian-7.8-64-nocm"
    debian78.vm.box_url = "puppetlabs/debian-7.8-64-nocm"
    debian78.vm.network "private_network", ip: "10.0.4.40"
    debian78.vm.network "forwarded_port", guest: 80, host: 8440
  end
  # debian 8.0
  config.vm.define "debian80" do |debian80|
    debian80.vm.box = "debian80"
    debian80.vm.box_url = "https://downloads.sourceforge.net/project/vagrantboxjessie/debian80.box"
    debian80.vm.network "private_network", ip: "10.0.4.50"
    debian80.vm.network "forwarded_port", guest: 80, host: 8450
  end
  # disable IPv6 on Linux
  $linux_disable_ipv6 = <<SCRIPT
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1
SCRIPT
  # stop iptables
  $service_iptables_stop = <<SCRIPT
service iptables stop
SCRIPT
  # stop firewalld
  $systemctl_stop_firewalld = <<SCRIPT
systemctl stop firewalld.service
SCRIPT
  # common settings on all machines
  $etc_hosts = <<SCRIPT
cat <<END >> /etc/hosts
10.0.4.5 puppet
10.0.4.10 rhel6
10.0.4.20 rhel7
10.0.4.30 ubuntu14
10.0.4.40 debian78
10.0.4.50 debian80
END
SCRIPT
  # set puppet on clients
  $etc_puppet_puppet_conf = <<SCRIPT
cat <<END >> /etc/puppet/puppet.conf
[agent]
server = puppet
END
SCRIPT
  # provision puppet clients
  $epel6 = <<SCRIPT
yum -y install http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
SCRIPT
  $rhel_puppet = <<SCRIPT
yum -y install puppet
SCRIPT
  $epel7 = <<SCRIPT
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
SCRIPT
  $debian_puppet = <<SCRIPT
apt-get update
apt-get -y install puppet
SCRIPT
  # puppetlabs on rhel6
  $puppetlabs_el6 = <<SCRIPT
yum -y install http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm
SCRIPT
  # run puppet agent
  $puppet_agent = <<SCRIPT
puppet agent --no-daemonize --onetime --ignorecache --no-splay --verbose
SCRIPT
  # provision puppetmaster
  $linux_puppetmaster_configure = <<SCRIPT
cat <<END > /etc/puppet/puppetdb.conf
[main]
server = puppet
port = 8081
END
cat <<END >> /etc/puppet/puppet.conf
[master]
autosign = true
storeconfigs = true
storeconfigs_backend = puppetdb
reports = store, puppetdb
END
cat <<END > /etc/puppet/routes.yaml
master:
       facts:
         terminus: puppetdb
         cache: yaml
END
SCRIPT
  # provision puppetmaster
  $service_puppetmaster_ssl_setup = <<SCRIPT
service puppetmaster start
puppetdb ssl-setup
SCRIPT
  # provision puppetmaster
  $service_puppetmaster_restart = <<SCRIPT
service puppetdb restart
service puppetmaster restart
SCRIPT
  # the actual provisions of machines
  config.vm.define "puppet" do |puppet|
    puppet.vm.provision :shell, :inline => "hostname puppet", run: "always"
    # don't let puppetmaster opening IPv6 ports
    puppet.vm.provision :shell, :inline => $linux_disable_ipv6, run: "always"
    puppet.vm.provision :shell, :inline => $etc_hosts
    puppet.vm.provision :shell, :inline => $puppetlabs_el6
    puppet.vm.provision :shell, :inline => "yum -y install puppet-server puppetdb puppetdb-terminus"
    puppet.vm.provision :shell, :inline => $linux_puppetmaster_configure
    puppet.vm.provision :shell, :inline => $service_puppetmaster_ssl_setup
    puppet.vm.provision :shell, :inline => $service_iptables_stop, run: "always"
    puppet.vm.provision :shell, :inline => $service_puppetmaster_restart, run: "always"
  end
  config.vm.define "rhel6" do |rhel6|
    rhel6.vm.provision :shell, :inline => "hostname rhel6", run: "always"
    rhel6.vm.provision :shell, :inline => $etc_hosts
    rhel6.vm.provision :shell, :inline => $epel6
    rhel6.vm.provision :shell, :inline => $rhel_puppet
    rhel6.vm.provision :shell, :inline => $etc_puppet_puppet_conf
    rhel6.vm.provision :shell, :inline => $puppet_agent, run: "always"
  end
  config.vm.define "rhel7" do |rhel7|
    rhel7.vm.provision :shell, :inline => "hostname rhel7", run: "always"
    rhel7.vm.provision :shell, :inline => $etc_hosts
    rhel7.vm.provision :shell, :inline => $epel7
    rhel7.vm.provision :shell, :inline => $rhel_puppet
    rhel7.vm.provision :shell, :inline => $etc_puppet_puppet_conf
    rhel7.vm.provision :shell, :inline => $puppet_agent, run: "always"
  end
  config.vm.define "ubuntu14" do |ubuntu14|
    ubuntu14.vm.provision :shell, :inline => "hostname ubuntu14", run: "always"
    ubuntu14.vm.provision :shell, :inline => $etc_hosts
    ubuntu14.vm.provision :shell, :inline => $debian_puppet
    ubuntu14.vm.provision :shell, :inline => $etc_puppet_puppet_conf
    ubuntu14.vm.provision :shell, :inline => "puppet agent --enable"
    ubuntu14.vm.provision :shell, :inline => $puppet_agent, run: "always"
  end
  config.vm.define "debian78" do |debian78|
    debian78.vm.provision :shell, :inline => "hostname debian78", run: "always"
    debian78.vm.provision :shell, :inline => $etc_hosts
    debian78.vm.provision :shell, :inline => $debian_puppet
    debian78.vm.provision :shell, :inline => $etc_puppet_puppet_conf
    debian78.vm.provision :shell, :inline => "puppet agent --enable"
    debian78.vm.provision :shell, :inline => $puppet_agent, run: "always"
  end
  config.vm.define "debian80" do |debian80|
    debian80.vm.provision :shell, :inline => "hostname debian80", run: "always"
    debian80.vm.provision :shell, :inline => $etc_hosts
    debian80.vm.provision :shell, :inline => $debian_puppet
    debian80.vm.provision :shell, :inline => $etc_puppet_puppet_conf
    debian80.vm.provision :shell, :inline => "puppet agent --enable"
    debian80.vm.provision :shell, :inline => $puppet_agent, run: "always"
  end
end
