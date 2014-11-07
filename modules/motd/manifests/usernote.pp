define motd::usernote($content = '') {

	include motd

   file { "/etc/update-motd.d/60-${name}":
      content  => $content,
   }
}