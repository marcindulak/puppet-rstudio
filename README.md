Description
-----------

A simple puppet module that installs and configures an RStudio server,
and optionally, apache/nginx proxy.
The module does not use any available apache/nginx or other puppet modules.


Sample Usage
------------

Create /etc/puppet/manifests/site.pp::

    node default {
        include rstudio
        #include rstudio::apache
        include rstudio::nginx
    }

apply with::

    sudo puppet apply --verbose /etc/puppet/manifests/site.pp


Configuration
-------------

In manifests/params.pp


Dependencies
------------

None


Todo
----

Works only on Ubuntu, adapt for RHEL!
