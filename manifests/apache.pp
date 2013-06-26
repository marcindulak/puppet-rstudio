class rstudio::apache {

    include rstudio::params

    package { "apache2":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    package { "libapache2-mod-proxy-html":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    package { "libxml2-dev":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    exec { "a2enmod proxy":
      command => '/usr/sbin/a2enmod proxy',
      require => Package['apache2', 'libapache2-mod-proxy-html'],
    }

    exec { "a2enmod proxy_http":
      command => '/usr/sbin/a2enmod proxy_http',
      require => Package['apache2', 'libapache2-mod-proxy-html'],
    }

    file {
      "/etc/apache2/conf.d/rstudio.conf":
      ensure  => file,
      content => template("rstudio/apache.erb"),
      require => Package['apache2'],
    }

    service {
      "apache2":
    ensure     => 'running',
      require    => [File['/etc/apache2/conf.d/rstudio.conf'],
                     Exec['a2enmod proxy', 'a2enmod proxy_http'] ],
      subscribe  => [
                     File['/etc/apache2/conf.d/rstudio.conf'],
                    ],
    }

}
