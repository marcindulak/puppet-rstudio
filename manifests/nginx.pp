class rstudio::nginx {
  
  include rstudio::params
  
  # needed by exec, otherwise one needs to provide full path to sed, grep, ...
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  case $::osfamily {
    'redhat': {
      $nginx_package = 'nginx'
      $nginx_service = 'nginx'
      $nginx_confdir = '/etc/nginx/conf.d'
    }
    'debian': {
      $nginx_package = 'nginx'
      $nginx_service = 'nginx'
      $nginx_confdir = '/etc/nginx/conf.d'
    }
    default: {
      $nginx_package = undef
      $nginx_service = undef
      $nginx_confdir = undef
    }
  }
  
  package { $nginx_package:
    ensure => installed,
    name => $nginx_package,
  }
  
  file { "${nginx_confdir}/rstudio.conf":
    ensure => file,
    content => template('rstudio/nginx.erb'),
    require => Package[$nginx_package],
  }
  
  service { $nginx_service:
    ensure => running,
    enable => true,
    require => File["${nginx_confdir}/rstudio.conf"],
    subscribe => File["${nginx_confdir}/rstudio.conf"],
  }

}
