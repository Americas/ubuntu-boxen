# .dotfile management setup with homeshick
# https://github.com/andsens/homeshick
class homeshick($username)
{
   $classes = ['bash','git']
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
      notify => Exec['source bash'],
   }

   # onlogin check if all managed files are updated
   bash::rc { 'homeshick refresh':
      content => '[ -d ~/.homesick ] && homeshick --quiet refresh',
      notify => Exec['source bash'],
   }

   # add auto completion
   bash::rc { 'homeshick autocompletions':
      content => '[ -d ~/.homesick ] && source $HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash',
      notify => Exec['source bash'],
   }

   motd::usernote { 'homeshick':
      content       => "dotfiles are managed by homeshick, for more info https://github.com/andsens/homeshick",
   }

   file { 'homeshick link':
      path          => '/usr/bin/homeshick',
      ensure        => link,
      target        => "${userhome}/.homesick/repos/homeshick/bin/homeshick",
   }

}