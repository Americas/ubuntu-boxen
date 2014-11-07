# Install Sublime Text 3 into /Applications
#
# Usage:
#
#     include sublime_text_3
class sublime_text_3 {

   wget::fetch { 'http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3065_amd64.deb':
      destination => '/tmp/sublime-text.deb',
  	   timeout     => 0,
  	   verbose     => false,
   }

   package { 'SublimeText3':
      provider => 'dpkg',
      ensure   => latest,
      source   => '/tmp/sublime-text.deb';
   }

   require sublime_text_3::config

   file { [
         $sublime_text_3::config::dir,
         $sublime_text_3::config::packages_dir,
         $sublime_text_3::config::user_packages_dir,
         $sublime_text_3::config::installed_packages_dir
      ]:
      ensure => directory
   }

   file { "/bin/subl":
      ensure  => link,
      target  => '/opt/sublime_text/sublime_text',
      mode    => '0755',
      require => Package['SublimeText3'],
   }
}