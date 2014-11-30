class rstudio (
  $port  = $rstudio::params::port,
  $size = $rstudio::params::size
  ) inherits rstudio::params {
  
  # needed by exec, otherwise one needs to provide full path to sed, grep, ...
  Exec {
    path => "/bin:/sbin:/usr/bin:/usr/sbin",
  }

  $rstudio_url_download = "http://download2.rstudio.org"  # no trailing '/'!

  case $::osfamily {
    "redhat": {
      $r_package = "R"
      $rstudio_package = "rstudio-server"
      $rstudio_pkgsrc = "rstudio-server-0.98.1091-x86_64.rpm"
      $rstudio_service = "rstudio-server"
      $rstudio_confdir = "/etc/rstudio"
    }
    "debian": {
      $r_package = "r-base"
      $rstudio_package = "rstudio-server"
      $rstudio_pkgsrc = "rstudio-server-0.98.1091-amd64.deb"
      $rstudio_service = "rstudio-server"
      $rstudio_confdir = "/etc/rstudio"
    }
    default: {
      $r_package = undef
      $rstudio_package = undef
      $rstudio_pkgsrc = undef
      $rstudio_service = undef
      $rstudio_confdir = undef
    }
  }

  package { $r_package:
    ensure => installed,
  }

  case $::operatingsystem {
    "ubuntu": {
      package { "libapparmor1":
        ensure => installed,
      }
    }
  }

  case $::osfamily {
    "debian": {
      package { "gdebi-core":  # installs local debs
        ensure => installed,
      }
    }
  }

  case $::osfamily {
    "debian": {
      package { "wget":
        ensure => installed,
      }
    }
  }

  # both debian and redhat require a specific openssl version
  # https://support.rstudio.com/hc/communities/public/questions/200651456-RStudio-server-not-installable-on-Debian-Wheezy-just-released-this-week-
  case $::osfamily {
    "debian": {  # gdebi can't install from http
      $ssl_url_download = "http://ftp.debian.org/debian/pool/main/o/openssl"  # no trailing '/'!
      $ssl_package = "libssl0.9.8"
      $ssl_pkgsrc = "libssl0.9.8_0.9.8o-4squeeze14_amd64.deb"
    }
    "redhat": {
      $ssl_url_download = "http://vault.centos.org/6.5/updates/x86_64/Packages"  # no trailing '/'!
      $ssl_package = "openssl098e"
      $ssl_pkgsrc = "openssl098e-0.9.8e-18.el6_5.2.x86_64.rpm"
    }
  }

  case $::operatingsystem {
    "debian": {  # gdebi can't install from http
      exec { "wget ssl":
        command => "wget ${ssl_url_download}/${ssl_pkgsrc} -P /root",
        onlyif => "test ! -r /root/$ssl_pkgsrc",
        require => Package["wget"],
      }
    }
  }

  case $::operatingsystem {
    "debian": {  # apt-get can't install local debs
      exec { "install ssl":
        command => "gdebi -n /root/$ssl_pkgsrc",
        require => [Package["gdebi-core"],
                    Exec["wget ssl"]],
        onlyif => "test ! -r /usr/share/doc/libssl0.9.8",
      }
    }
    "ubuntu": {
      exec { "install ssl":
        command => "apt-get install -y $ssl_package",
        onlyif => "test ! -r /usr/share/doc/libssl0.9.8",
      }
    }
    "fedora": {
      case $::operatingsystemrelease {
        "20", "21": {  # Fedora >= 20 does not provide openssl098e
          exec { "install ssl":
            command => "yum -y install ${ssl_url_download}/${ssl_pkgsrc}",
            onlyif => "test ! -r /usr/lib64/openssl098e",
          }
        }
      }
    }
    "redhat", "centos", "scientific": {
      exec { "install ssl":
        command => "yum -y install $ssl_package",
        onlyif => "test ! -r /usr/lib64/openssl098e",
      }
    }
  }

  case $::osfamily {
    "debian": {  # gdebi can't install from http
      exec { "wget rstudio-server":
        command => "wget ${rstudio_url_download}/${rstudio_pkgsrc} -P /root",
        onlyif => "test ! -r /root/$rstudio_pkgsrc",
        require => Package["wget"],
      }
    }
  }

  case $::osfamily {
    "debian": {  # apt-get can't install local debs
      exec { "gdebi rstudio-server":
        command => "gdebi -n /root/$rstudio_pkgsrc",
        require => [Package[$r_package, "gdebi-core"],
                    Exec["wget rstudio-server", "install ssl"]],
        onlyif => "test ! -r /usr/lib/rstudio-server",
      }
    }
    "redhat": {
      exec { "yum rstudio-server":
        command => "yum -y install ${rstudio_url_download}/${rstudio_pkgsrc}",
        require => [Package[$r_package],
                    Exec["install ssl"]],
        onlyif => "test ! -r /usr/lib/rstudio-server",
      }
    }
  }

  case $::osfamily {
    "redhat": {  # the RPM does not install /etc/init.d scripts
      exec { "/etc/init.d/rstudio-server":
        command => "cp -p /usr/lib/rstudio-server/extras/init.d/redhat/rstudio-server /etc/init.d/rstudio-server",
        require => Exec["yum rstudio-server"],
        onlyif => "test ! -r /etc/init.d/rstudio-server",
      }
    }
  }

  file { "$rstudio_confdir/rserver.conf":
    ensure => file,
    content => template("rstudio/rserver.erb"),
    require => $::osfamily ? {
      "debian" => Exec["gdebi rstudio-server"],
      "redhat" => Exec["yum rstudio-server"],
    }
  }

  file { "$rstudio_confdir/rsession.conf":
    ensure => file,
    content => template("rstudio/rsession.erb"),
    require => $::osfamily ? {
      "debian" => Exec["gdebi rstudio-server"],
      "redhat" => Exec["yum rstudio-server"],
    }
  }

  service { $rstudio_service:
    ensure => running,
    enable => true,
    require => File["$rstudio_confdir/rserver.conf",
                    "$rstudio_confdir/rsession.conf"],
    subscribe => File["$rstudio_confdir/rserver.conf",
                      "$rstudio_confdir/rsession.conf"],
  }

  exec { "rstudio-server verify-installation":
    command => "rstudio-server verify-installation",
    require => Service["$rstudio_service"],
  }

}
