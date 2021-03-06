define common::line { }

node default {

   # General DEFAULTS
   Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

   include bash

   # Common utilities
   $common_packages = [
      'htop',
      'ipcalc',
      'hwdata',
      'mercurial',
      'subversion',
      'aptitude',
      'ppa-purge',
      'curl',
      'pwgen',
      'nmap',
      'tcpdump'
   ]
   package { $common_packages : 
      ensure => latest 
   }

   include etckeeper
   include apt
   include wget
   include docker
   include vagrant 
   include apache

   $unix_user = $::ubuser
   $unix_home = "/home/${unix_user}"

   git::config { 'user.name'            : value => $::gitlogin  , user => $unix_user }
   git::config { 'user.email'           : value => $::gitemail  , user => $unix_user }
   git::config { 'push.default'         : value => 'simple'     , user => $unix_user }
   git::config { 'alias.up'             : value => 'pull origin'                     }
   git::config { 'core.sharedRepository': value => 'group'                           }
   git::config { 'color.interactive'    : value => 'auto'                            }
   git::config { 'color.showbranch'     : value => 'auto'                            }
   git::config { 'color.status'         : value => 'auto'                            }

   git::reposync { 'ubuntu-boxen':
      source_url      => 'https://github.com/Americas/ubuntu-boxen.git',
      destination_dir => '/opt/ubuntu-boxen',
      autorun         => false,
      cron            => '0 9-18 * * *',
      owner           => $unix_user,
      group           => $unix_user,
      mode            => '7550',
   }
   
   # Security
   class { 'sudo': 
      #require => Package['ruby-hiera'],
   }

   class { 'homeshick':
      username => $unix_user,
   }

   sudo::conf { $unix_user:
      priority => 10,
      content  => "${unix_user} ALL=(ALL) NOPASSWD: ALL",
   }
 
   user { $unix_user :
      groups => [ 'adm', 'sudo' ],
   }

   homeshick::clone{'homeshick dotfiles':
     username => $unix_user,
     gitlogin => $::gitlogin,
     repo     => 'dotfiles'
   }

   homeshick::clone{'homeshick scripts':
     username => $unix_user,
     gitlogin => $::gitlogin,
     repo     => 'scripts'
   }

   # General dns conf
   dnsmasq::conf { 'no-negcache':
      content => 'no-negcache'
   }

   # Debugging dnsmasq conf
   #dnsmasq::conf { 'log-queries':
   #   content => 'log-queries'
   #}
   #dnsmasq::conf { 'log-async':
   #   content => 'log-async=25'
   #}

   # Dev Environment
   dnsmasq::conf { 'address':
      content => 'address=/dev.u9/127.0.1.1'
   }
   motd::usernote { 'dnsmasq':
      content => "Domain dev.u9 points to localhost, use it for your dev environments",
   }

   include sublime_text_3
   include sublime_text_3::package_control

   apt::source { 'canonical-partner':
      location  	=> 'http://archive.canonical.com/ubuntu',
      repos     	=> 'partner',
      include_src => true
   }

   # Google 
   apt::key { 'google-repo-key':
  	   key => '7FAC5991',
  	   key_source  => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
   }

   apt::source { 'google-chrome':
      location    => 'http://dl.google.com/linux/chrome/deb/',
      release     => 'stable',
      key         => '7FAC5991',
      include_src => false,
   }

   apt::source { 'google-talkplugin':
      location  	=> 'http://dl.google.com/linux/talkplugin/deb/',
      release   	=> 'stable',
      key         => '7FAC5991',
      include_src => false,
   }

   package { 'skype':
      require => Apt::Source['canonical-partner'],
   }

   package { 'dkms':
  	   ensure	=> latest
   }

   # PHP development env
   include php
   php::module { "json": }
   php::module { "curl": }
   php::module { "sybase": }
   php::module { "mcrypt": }
   php::module { "pgsql": }
   php::module { "mysql": }
   php::module { "odbc": }

   #$mods = ["mcrypt"]
   #php::mod { "$mods": }

   class { 'composer':
      require => Package ['php5-curl'],
   }

   bash::rc { 'Add user bin to path':
      content => 'export PATH=~/bin:$PATH',
   }
 
   bash::rc { 'Set terminal to hicolor in X':
      content => '[ -n "$DISPLAY" -a "$TERM" == "xterm" ] && export TERM=xterm-256color',
   }

   bash::rc { 'HISTTIMEFORMAT="[%Y-%m-%d - %H:%M:%S] "': }
   bash::rc { 'alias ll="ls -lv --group-directories-first"': }
   bash::rc { 'alias rm="rm -i"': }
   bash::rc { 'alias mv="mv -i"': }
   bash::rc { 'alias mkdir="mkdir -p"': }
   bash::rc { 'alias df="df -kTh"': }
   bash::rc { 'alias ..="cd .."': }
   bash::rc { 'alias svim="sudo vim"': }
   bash::rc { 'Sort by date, most recent last': 
      content => 'alias lt="ls -ltr"' 
   }
   bash::rc { 'Sort by size, biggest last': 
      content => 'alias lk="ls -lSr"' 
   }
   bash::rc { 'alias grep="grep --color=always"': }

   bash::rc { 'alias update="sudo apt-get update"': }
   bash::rc { 'alias upgrade="update && sudo apt-get upgrade"': }
   bash::rc { 'alias install="sudo apt-get install"': }

   bash::rc { 'alias netscan="nmap -A -sP"': }
   bash::rc { 'alias netscan0="nmap -A -PN"': }
   bash::rc { 'alias hostscan="nmap -A -T4"': }

   bash::rc { 'alias goodpass="pwgen -scnvB -C 16 -N 1"': }
   bash::rc { 'alias goodpass8="pwgen -scnvB -C 8 -N 1"': }
   bash::rc { 'alias strongpass="pwgen -scynvB -C 16 -N 1"': }
   bash::rc { 'alias strongpass8="pwgen -scynvB -C 8 -N 1"': }

   bash::rc { 'Command-line calculator': 
      content => "calc (){\n\techo \"\$*\" | bc -l;\n}",
   }

   #Vagrant box Homestead
   vagrant::box { 'Laravel':
      source   => "https://github.com/laravel/homestead.git",
      username => $unix_user,
   }
}
