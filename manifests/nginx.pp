class rstudio::nginx {

    include rstudio::params

    package { "nginx":
    ensure => latest,
      require => Exec['apt-get update'],
    }

    file {
      "/etc/nginx/conf.d/rstudio.conf":
      ensure  => file,
      content => template("rstudio/nginx.erb"),
      require    => Package['nginx'],
    }

    service {
      "nginx":
    ensure     => 'running',
      require    => Package['nginx'],
      subscribe  => [
                     File['/etc/nginx/conf.d/rstudio.conf'],
                    ],
    }

}
