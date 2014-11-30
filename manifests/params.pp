class rstudio::params {

  # http://www.rstudio.com/ide/docs/server/configuration

  # The port rstudio will listen on,
  # the default is 8787
  $port = 8787

  # The maximum file size to upload (in MB)
  $size = 20

  # The maximum memory limit (in MB)
  $mlimit = 300

  case $::osfamily {
    "redhat": {
      $apache_logdir = "/var/log/httpd"
    }
    "debian": {
      $apache_logdir = "/var/log/apache2"
    }
    default: {
      $apache_logdir = "/var/log"
    }
  }

}
