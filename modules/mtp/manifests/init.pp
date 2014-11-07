# MTP Support to mount Android Devices
class mtp {
  	package { [ 'mtp-tools', 'mtpfs' ] :
    	ensure => latest,
  	}

  	# missing: add-apt-repository ppa:langdalepl/gvfs-mtp
}