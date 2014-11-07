# Public: Manages vagrant boxes
#
define vagrant::box(
   $source,
   $username = 'root',
) {

   include vagrant

   $home = $username ? {
      'root'  => '/root',
      default => "/home/${username}"
   }

   if ! defined(File['vagrant-home']) {
      file { 'vagrant-home':
         path   => "${home}/vagrant",
         owner  => $username,
         ensure => directory,
      }
   }

   vcsrepo { "${home}/vagrant/${name}":
      source   => $source,
      ensure   => present,
      provider => git,
      require  => Package['git'],
   }

   file { "${home}/vagrant/${name}":
      owner   => $username,
      recurse => true,
   }
}