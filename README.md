-----------
Description
-----------

A puppet module that installs and configures an RStudio server, and
optionally, apache/nginx localhost proxy, on amd64 Debian(Ubuntu) or x86_64 RHEL(Fedora)
The module does not use any available apache/nginx or other puppet modules.

Tested on: Debian 7/8, Ubuntu 14.04, and RHEL 6/7, Fedora 20.

------------
Sample Usage
------------

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

1. proxies (more often nginx) are not working on all platforms.

2. upstart start/stop of **rstudio-server** hangs on Ubuntu 14.04.
   Permanently disabling **apparmor** does not seem to help:
   https://support.rstudio.com/hc/en-us/articles/200717193-RStudio-Server-Will-Not-Start

