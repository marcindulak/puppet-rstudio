class rstudio::apache {
  
  include rstudio::params
  
  # needed by exec, otherwise one needs to provide full path to sed, grep, ...
  Exec {
    path => "/bin:/sbin:/usr/bin:/usr/sbin",
  }

  case $::osfamily {
    "redhat": {
      $apache_package = "httpd"
      $apache_service = "httpd"
      $apache_confdir = "/etc/httpd/conf.d"
      $libxml2_devel_package = "libxml2-devel"
    }
    "debian": {
      $apache_package = "apache2"
      $apache_service = "apache2"
      case $::operatingsystemrelease {
        /^7.*$/: {  # Debian 7
          $apache_confdir = "/etc/apache2/conf.d"
        }
        default: {
          $apache_confdir = "/etc/apache2/conf-available"
        }
      }
      $libxml2_devel_package = "libxml2-dev"
    }
    default: {
      $apache_package = undef
      $apache_service = undef
      $apache_confdir = undef
      $libxml2_devel_package = undef
    }
  }
  
  package { $apache_package:
    name => $apache_package,
    ensure => installed,
  }
  
  #package { $libxml2_devel_package:
  #  name => $libxml2_devel_package,
  #  ensure => installed,
  #}
    
  case $::osfamily {
    "debian": {
      package { "libapache2-mod-proxy-html":
        ensure => installed,
        require => Package[$apache_package],
      }
    }
  }
  
  case $::osfamily {
    "debian": {
      exec { "a2enmod proxy":
        command => "a2enmod proxy",
        require => Package[$apache_package,
                           "libapache2-mod-proxy-html"],
      }
    }
  }
  
  case $::osfamily {
    "debian": {
      exec { "a2enmod proxy_http":
        command => "a2enmod proxy_http",
        require => Package[$apache_package,
                           "libapache2-mod-proxy-html"],
      }
    }
  }
  
  file { "$apache_confdir/rstudio.conf":
    ensure => file,
    content => template("rstudio/apache.erb"),
    require => Package[$apache_package],
  }
  
  service { $apache_service:
    ensure => running,
    enable => true,
    require => $::osfamily ? {
      'debian' => [File["$apache_confdir/rstudio.conf"],
                   Exec["a2enmod proxy", "a2enmod proxy_http"]],
      'redhat' => File["$apache_confdir/rstudio.conf"],
    },
    subscribe => File["$apache_confdir/rstudio.conf"],
  }

}
