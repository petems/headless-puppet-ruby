class ruby($version = "2.0.0-p0") {
  rubyinstall { "$version": }
}

define rubyinstall($version = $title) {
  package {
    "build-essential":
      ensure => present;
    "libssl-dev":
      ensure => present;
    "libreadline6":
      ensure => present;
    "libreadline6-dev":
      ensure => present;
    "zlib1g":
      ensure => present;
    "zlib1g-dev":
      ensure => present;
    "curl":
      ensure => present;
    "git":
      ensure => present;
    "rake":
      ensure => present
  }

  exec { "ruby-build-checkout":
    command => "rm -Rf /opt/ruby-build && git clone https://github.com/sstephenson/ruby-build /opt/ruby-build",
    creates => "/opt/ruby-build/.git",
    require => [
      Package["curl"],
      Package["git"],
      Package["rake"],
      Package["build-essential"],
      Package["libssl-dev"],
      Package["libreadline6"],
      Package["libreadline6-dev"],
      Package["zlib1g"],
      Package["zlib1g-dev"]
    ],
    timeout => 0
  }

  exec { "ruby-build-update":
    command => "git checkout -f && git pull origin master",
    cwd     => "/opt/ruby-build",
    require => Exec["ruby-build-checkout"],
    timeout => 0
  }

  exec { "ruby-install-$version":
    command => "/opt/ruby-build/bin/ruby-build $version /opt/ruby-$version",
    creates => "/opt/ruby-$version",
    require => Exec["ruby-build-update"],
    timeout => 0
  }

  exec { "alternatives-ruby-$version":
    command => "update-alternatives --quiet --install /usr/bin/ruby ruby /opt/ruby-$version/bin/ruby 10 --slave /usr/bin/irb irb /opt/ruby-$version/bin/irb && update-alternatives --quiet --set ruby /opt/ruby-$version/bin/ruby",
    unless  => "test /usr/bin/ruby -ef /opt/ruby-$version/bin/ruby && test /usr/bin/irb -ef /opt/ruby-$version/bin/irb",
    require => Exec["ruby-install-$version"]
  }

  exec { "alternatives-gem-$version":
    command => "update-alternatives --quiet --install /usr/bin/gem gem /opt/ruby-$version/bin/gem 10 && update-alternatives --quiet --set gem /opt/ruby-$version/bin/gem",
    unless  => "test /usr/bin/gem -ef /opt/ruby-$version/bin/gem",
    require => Exec["alternatives-ruby-$version"]
  }

  exec { "gem-install-bundler-$version":
    command => "gem install bundler",
    unless  => "gem list | grep bundler",
    timeout => "-1",
    require => Exec["alternatives-gem-$version"]
  }

  exec { "alternatives-bundle-$version":
    command => "update-alternatives --quiet --install /usr/bin/bundle bundle /opt/ruby-$version/bin/bundle 10 && update-alternatives --quiet --set bundle /opt/ruby-$version/bin/bundle",
    unless  => "test /usr/bin/bundle -ef /opt/ruby-$version/bin/bundle",
    require => Exec["gem-install-bundler-$version"]
  }
}
