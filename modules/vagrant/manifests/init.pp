# Public: Installs Vagrant
#
# Usage:
#
#   include vagrant

class vagrant {

   $classes = ['bash']
   include $classes

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