# == Class: cron::config
#
#  Hardening of system crontab
#
# === Parameters
#
#
# === Variables
#
#
# === Examples
#
# include cron::config
#
# === Authors
#
# PeteMS
#
class cron::config {

  file {'/etc/crontab' :
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
  }

  file {'/var/spool/cron' :
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    force   => true,
    mode    => '0711',
  }

  file {'/var/spool/cron/crontabs' :
    ensure  => directory,
    force   => true,
    group   => 'crontab',
    mode    => '1730',
    require => File['/var/spool/cron'],
  }

  exec { 'reset-crontab-permissions' :
    command  => '/bin/chmod 0600 *',
    cwd      => '/var/spool/cron/crontabs',
    provider => shell,
    unless   => [
      'for F in *; do echo $(/usr/bin/stat -c %a $F) | /bin/grep "600" || exit 1; done',
      '[ -d /var/spool/cron/crontabs ]',
    ],
    require  => File['/var/spool/cron/crontabs'],
  }

  exec { 'reset-crontab-group' :
    command  => '/bin/chgrp crontab *',
    cwd      => '/var/spool/cron/crontabs',
    provider => shell,
    unless   => [
      'for F in *; do echo $(/usr/bin/stat -c %G $F) | /bin/grep "crontab" || exit 1; done',
      '[ -d /var/spool/cron/crontabs ]',
    ],
    require  => File['/var/spool/cron/crontabs'],
  }

  file {'/var/spool/cron/crontabs/root' :
    ensure  => file,
    force   => true,
    owner   => 'root',
    group   => 'crontab',
    mode    => '0600',
    require => File['/var/spool/cron'],
  }

  file {'/var/spool/cron/atspool' :
    ensure  => directory,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    recurse => true,
    require => File['/var/spool/cron'],
  }

    file {'/var/spool/cron/atjobs' :
    ensure  => directory,
    force   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    recurse => true,
    require => File['/var/spool/cron'],
  }

  file { [
    '/etc/cron.daily',
    '/etc/cron.hourly',
    '/etc/cron.weekly',
    '/etc/cron.monthly',
    ] :
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  }

}
