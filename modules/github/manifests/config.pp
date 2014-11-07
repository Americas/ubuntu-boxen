# = Define a git config
#
# == Parameters:
#
# $section::   The section of the config
# $key::       The name of the config
# $value::     The value for the config
# $user::      The user to save the config (defaults to system config)
#
# == Usage:
#
# github::config { 'color.status' :          
#   value => 'auto' 
# }
#
# github::config { 'color' :
#   section => 'color',
#   key     => 'status',
#   value   => 'auto',
#   user    => $::id
# }

define github::config(
   $section = '', 
   $key = '', 
   $value, 
   $user = ''
) {

   include github

   if empty($user)
   {
      $real_command = "git config --system"
   } 
   else 
   {
      validate_string($user)
      $real_command = "sudo -u ${user} git config --global"
   }

   if empty($section) and empty($key) 
   {
      validate_re($name, '^\w+\.\w+$')
      $real_section_key = $name
   } 
   else 
   {
      $real_section_key = "${section}.${key}" 
   }

   exec { $real_section_key:
      command => "${real_command} ${real_section_key} \"$value\"",
      unless  => "test \"`${real_command} ${real_section_key}`\" = \"${value}\"",
      require => Package['git'],
   }
}