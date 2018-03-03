Vagrant.configure('2') do |config|
  config.vm.box = 'debian/stretch64'
  config.vm.network :public_network, bridge: File.read('tmp/ethernet-device.txt').chomp
  config.vm.network :private_network, ip: '192.168.42.3'

  if RbConfig::CONFIG['host_os'] =~ /mswin32/
    config.vm.synced_folder '.', '/vagrant', type: 'virtualbox'
  else
    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
  end

  config.vm.provider :virtualbox do |v|
    v.cpus = 1
    v.memory = 1024
  end

  config.vm.provision :shell, path: 'script/vagrant/update-system.sh'
  config.vm.provision :shell, path: 'script/vagrant/provision.sh'
end

# vim: ft=ruby
