#Sublime Text 3 & Package Control
class sublime_text_3::config {
  $dir = "/home/$::id/.config/sublime-text-3"
  $packages_dir = "${dir}/Packages"
  $user_packages_dir = "${packages_dir}/User"
  $installed_packages_dir = "${dir}/Installed Packages"

  anchor { [
    $dir,
    $packages_dir,
    $user_packages_dir,
    $installed_packages_dir
  ]: }
}

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

class sublime_text_3::package_control {
  sublime_text_3::package { 'Package Control':
    source => 'https://sublime.wbond.net/Package%20Control.sublime-package'
  }
}


define sublime_text_3::package($source, $branch = 'master') {
  require sublime_text_3::config

  if $source =~ /\.sublime-package$/ {
    $package_file = "${sublime_text_3::config::installed_packages_dir}/${name}.sublime-package"
    exec { "download Sublime Text 3 package '${name}'":
      command => "curl ${source} -L -q -o '${package_file}'",
      creates => $package_file,
      require => File[$sublime_text_3::config::installed_packages_dir]
    }
  } else {
    repository { "${sublime_text_3::config::packages_dir}/${name}":
      ensure => $branch,
      source => $source,
    }
  }
}