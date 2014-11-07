node default {

   $unix_user = $::id
   $unix_home = "/home/${unix_user}"

   github::config { 'user.name' : user => $unix_user, value => $::GITNAME }
   github::config { 'user.email': user => $unix_user, value => $::GITEMAIL }
   github::config { 'alias.up' :              value => 'pull origin' }
   github::config { 'core.sharedRepository':  value => 'group' }
   github::config { 'color.interactive':      value => 'auto' }
   github::config { 'color.showbranch':       value => 'auto' }
   github::config { 'color.status' :          value => 'auto' }

   # Security
   class { 'sudo': 
      require => Package['ruby-hiera'],
   }

   sudo::conf { $unix_user:
      priority => 10,
      content  => "${unix_user} ALL=(ALL) NOPASSWD: ALL",
   }
 
   user { $unix_user :
      groups => [ 'adm', 'sudo' ],
   }
 
   # PRL:TOFIX
   #class { 'homeshick':
   #  username => $unix_user,
   #}

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
      content => "Domain dev.it points to localhost, use it for your dev environments",
   }

   include etckeeper
   include bash
   include apt
   include wget
   include docker
   include vagrant 
   include sublime_text_3
   include sublime_text_3::package_control

   apt::source { 'canonical-partner':
      location  	=> 'http://archive.canonical.com/ubuntu',
      repos     	=> 'partner',
      include_src => true
   }

   # Google 
   apt::key { 'google-repo-key':
  	   key        => '4CCA1EAF950CEE4AB83976DCA040830F7FAC5991',
  	   key_source => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
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

   # General DEFAULTS
   Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin" }

   # Common utilities
   $common_packages = [
      'puppet',
      'ruby-hiera',
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
      'tcpdump',
   ]
   package { $common_packages : ensure => latest }

   # Puppet config
   file { '/etc/puppet/hiera.yaml':
      content	=> '---',
      require	=> Package['ruby-hiera'],
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
   bash::rc { 'Sort by date, most recent last': content => 'alias lt="ls -ltr"' }
   bash::rc { 'Sort by size, biggest last': content => 'alias lk="ls -lSr"' }
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
}
