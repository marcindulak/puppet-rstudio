class rstudio (
     $port  = $rstudio::params::port,
     $size = $rstudio::params::size
     ) inherits rstudio::params {

    exec { 'apt-get update':
      command => '/usr/bin/apt-get update',
      before => Package['r-base', 'gdebi-core', 'libapparmor1', 'wget'],
    }

    package { "r-base":
    ensure => latest,
      require => Exec['apt-get update'],
    }
    
    package { "gdebi-core":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    package { "libapparmor1":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    package { "wget":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    exec { 'wget rstudio-server':
      command => '/bin/rm -f /root/rstudio-server-0.97.551-i386.deb&& /usr/bin/wget http://download2.rstudio.org/rstudio-server-0.97.551-i386.deb -P /root',
      require => Package['wget'],
    }

    exec { 'gdebi rstudio-server':
      command => '/usr/bin/gdebi -n /root/rstudio-server-0.97.551-i386.deb',
      require => [ Exec['wget rstudio-server'],
                   Package['r-base', 'gdebi-core', 'libapparmor1'] ],
    }

    file {
      "/etc/rstudio/rserver.conf":
      ensure  => file,
      content => template("rstudio/rserver.erb"),
      require => Exec['gdebi rstudio-server'],
    }

    file {
      "/etc/rstudio/rsession.conf":
      ensure  => file,
      content => template("rstudio/rsession.erb"),
      require => Exec['gdebi rstudio-server'],
    }

    service {
      "rstudio-server":
      provider   => $operatingsystem ? {
        'Ubuntu' => 'upstart',
        default  => undef,
      },
    ensure     => 'running',
      require    => Exec['gdebi rstudio-server'],
      subscribe  => [
                     File['/etc/rstudio/rserver.conf'],
                     File['/etc/rstudio/rsession.conf'],
                    ],
    }

    exec { 'rstudio-server verify-installation':
      command => '/usr/sbin/rstudio-server verify-installation',
      require => Service['rstudio-server'],
    }
  }

