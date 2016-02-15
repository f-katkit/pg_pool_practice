# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vbguest.auto_update = false
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.define :postgres1 do |host|
    host.vm.box = "ubuntu_trasty_a"
    host.vm.hostname = "postgres1"
    host.vm.box_url = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'
    host.vm.network :private_network, ip: "192.168.33.12"
    host.vm.provision :shell, :path => 'a.sh'
  end

  config.vm.define :postgres2 do |host|
    host.vm.box = "ubuntu_trasty_b"
    host.vm.hostname = "postgres2"
    host.vm.box_url = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'
    host.vm.network :private_network, ip: "192.168.33.13"
    host.vm.provision :shell, :path => 'b.sh'
  end

end
