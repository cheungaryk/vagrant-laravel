Vagrant.configure(2) do |config|
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder "app/", "/var/www/html/latest", :owner => "vagrant", :group => "www-data", :mount_option => ["dmode=775", "fmode=644"]
 config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
  end
  config.vm.provision "shell", path: "provision.sh"
end
