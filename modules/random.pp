# dnsmasq on a desktop is managed by network manager
# no modules on forge manage this
define dnsmasq::conf($value=''){
  file { "/etc/NetworkManager/dnsmasq.d/${name}":
    content => $value ? { 
    '' 	=> "${name}", 
    default 	=> "${name}=${value}",
    }
  }
}

define motd::usernote($content = '') {
  file { "/etc/update-motd.d/60-${name}":
    content  => $content,
  }
}