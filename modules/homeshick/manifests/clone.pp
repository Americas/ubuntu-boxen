define homeshick::clone(
	$username,
	$gitlogin,
	$repo
) {

	include homeshick

	validate_string($username)
	validate_string($repo)
   $userhome = "/home/${username}"
   validate_absolute_path($userhome)

   exec { "homeshick clone ${repo}":
      command => "sudo -u ${username} homeshick clone https://github.com/${gitlogin}/${repo}.git",
      creates => "${userhome}/.homesick/repos/${repo}",
      unless  => "curl -s --head --location -w %{http_code} https://github.com/${gitlogin}/${repo}.git -o /dev/null | grep -c 404",
      require => File['homeshick link']
   }
  	~> exec { "sudo -u ${username} homeshick link ${repo}":
    	refreshonly => true
  	}
}