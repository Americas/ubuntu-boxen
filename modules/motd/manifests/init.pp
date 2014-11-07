class motd 
{
	file { "/etc/update-motd.d/":
		ensure => directory
	}
}