-----------
Description
-----------

**Warning**: not maintained anymore!

A puppet module that installs and configures an RStudio server, and
optionally, apache/nginx localhost proxy, on amd64 Debian(Ubuntu) or x86_64 RHEL(Fedora)
The module does not use any available apache/nginx or other puppet modules.

Tested on: Debian 7/8, Ubuntu 14.04, and RHEL 6/7, Fedora 20.

------------
Sample Usage
------------

Assuming you have Vagrant installed from https://www.vagrantup.com/downloads.html
test the module with::

        $ git clone https://github.com/marcindulak/puppet-rstudio.git
        $ cd puppet-rstudio

If you prefer using nginx instead of the default apache, do::

        $ sed -i '/::apache/d' tests/site.pp
        $ sed -i 's/#//' tests/site.pp

Then start and provision virtual machines (VM) with::

        $ vagrant up

Test the basic HTTP from RStudio with curl or firefox, e.g. on the RHEL6 machine::

        $ vagrant ssh rhel6 -c "sudo su -c 'service iptables stop'"
        $ curl -v http://127.0.0.1:8410
        $ firefox http://127.0.0.1:8410

See [Vagrantfile](Vagrantfile) for the port numbers.

Note: in order to login into an RStudio running in Vargant's VM
you would need to create a user inside of VM.

When done, destroy the test machines with::

        $ vagrant destroy -f


0. Configuration
----------------

See the configuration options in manifests/params.pp.
The version of rstudio-server is hard-coded in manifests/init.pp


1. Install the module and dependencies
--------------------------------------

* on Debian/Ubuntu::

        $ sudo apt-get -y install puppet git
        $ cd /etc/puppet/modules
        $ sudo mkdir -p ../manifests
        $ sudo git clone https://github.com/marcindulak/puppet-rstudio.git
        $ sudo ln -s puppet-rstudio rstudio

* on RHEL/Fedora (on RHEL enable the EPEL repository https://fedoraproject.org/wiki/EPEL)::

        $ su -c "yum -y install puppet git"
        $ cd /etc/puppet/modules
        $ su -c "mkdir -p ../manifests"
        $ su -c "git clone https://github.com/marcindulak/puppet-rstudio.git"
        $ su -c "ln -s puppet-rstudio rstudio"


2. Configure the module:
-------------------------------------------------------------------------

As root user, create the /etc/puppet/manifests/site.pp file::

    node default {
        include rstudio
        include rstudio::apache
        #include rstudio::nginx
    }

Change permissions so only root can read your credentials::

        # chmod go-rwx /etc/puppet/manifests/site.pp


3. Apply the module:
--------------------

* on Debian/Ubuntu:

        $ sudo puppet apply --verbose --debug /etc/puppet/manifests/site.pp

* on RHEL/Fedora:

        $ su -c "puppet apply --verbose /etc/puppet/manifests/site.pp"


------------
Dependencies
------------

None


----
Todo
----

Maybe a more recent version of RStudio improves this?

1. proxies (more often nginx) are not working on all platforms.

2. upstart start/stop of **rstudio-server** hangs on Ubuntu 14.04.
   Permanently disabling **apparmor** does not seem to help:
   https://support.rstudio.com/hc/en-us/articles/200717193-RStudio-Server-Will-Not-Start

3. In version 0.98.1091 there is an old openssl dependency trailing.

