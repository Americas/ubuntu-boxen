class homeshick::params (
	$username = 'root',
	$gitlogin = ''
) {

   validate_string($username)
	$real_username = $username

	if $username != 'root' {
   	$real_userhome = "/home/${username}"
	}
   else {
   	$real_userhome = "/"
   }
	validate_absolute_path($real_userhome)

   $real_homeshick_path = "/.homesick/repos/homeshick"


   if !empty($gitlogin) {
      $real_gitlogin = $gitlogin
   }
}