class vagrant {

  package { 'virtualbox': 
  	ensure	=> latest 
  }
  
  package { 'vagrant':
  	ensure	=> latest 
  }
  
  wget::fetch { 'vagrant-bash-completion':
    source      => 'https://raw.githubusercontent.com/kura/vagrant-bash-completion/master/etc/bash_completion.d/vagrant',
    destination => '/etc/bash_completion.d/vagrant',
  }

  bash::rc { 'alias vu="vagrant up"' : }
  bash::rc { 'alias vs="vagrant suspend"' : }

}

define vagrant::box(
  $source,
  $username = 'root',
){

  include vagrant

  $home = $username ? {
    'root'  => '/root',
    default => "/home/${username}"
  }
 
  if ! defined(File['vagrant-home']) {
    file { 'vagrant-home':
      path   => "${home}/vagrant",
      owner  => $username,
      ensure => directory,
    }
  }
 
  vcsrepo { "${home}/vagrant/${name}":
    source   => $source,
    ensure   => present,
    provider => git,
    require  => Package['git'],
  }

  file { "${home}/vagrant/${name}":
    owner   => $username,
    recurse => true,
  }
}