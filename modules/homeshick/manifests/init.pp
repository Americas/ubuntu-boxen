# .dotfile management setup with homeshick
# https://github.com/andsens/homeshick
class homeshick($username)
{
   $classes = ['bash', 'vcsrepo', 'motd::usernote']
   include $classes

   validate_string($username)
   $userhome = "/home/${username}"
   validate_absolute_path($userhome)
  
   file { "${userhome}/.homesick" :
      ensure        => directory,
      owner         => $username,
      recurse       => true,
   }

   vcsrepo { "${userhome}/.homesick/repos/homeshick" :
      ensure      => present,
      source      => 'git://github.com/andsens/homeshick.git',
      provider    => git,
      require     => Package['git'],
   }

   bash::rc { 'homeshick command':
      content => '[ -d ~/.homesick ] && source $HOME/.homesick/repos/homeshick/homeshick.sh',
   }

   # onlogin check if all managed files are updated
   bash::rc { 'homeshick refresh':
      content => '[ -d ~/.homesick ] && homeshick --quiet refresh',
   }

   motd::usernote { 'homeshick':
      content       => "dotfiles are managed by homeshick, for more info https://github.com/andsens/homeshick",
   }

   # basic setup for the first use:
   # homeshick generate dotfiles
   # homeshick track dotfiles ~/.bashrc
   exec { "homeshick clone ${username}/dotfiles":
      creates       => "${userhome}/.homesick/repos/dotfiles",
   }
   exec { "homeshick clone ${username}/scripts":
      creates       => "${userhome}/.homesick/repos/scripts",
   }
}