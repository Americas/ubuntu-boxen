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