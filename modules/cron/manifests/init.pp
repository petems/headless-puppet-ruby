# == Class: cron
#
#  Initialisaion of the system crontab
#
# === Parameters
#
#
# === Variables
#
#
# === Examples
#
# include cron
#
# === Authors
#
# PeteMS
#
class cron {
  include cron::config

  service { 'cron':
    ensure  =>  running,
  }
}
