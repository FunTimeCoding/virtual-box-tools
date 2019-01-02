Vagrant.configure('2') do |c|
  c.vm.box = 'debian/stretch64'
  Dir.mkdir('tmp') unless File.exist?('tmp')

  if File.exist?('tmp/ethernet-device.txt')
    bridge = File.read('tmp/ethernet-device.txt').chomp
  else
    if RbConfig::CONFIG['host_os'] =~ /mswin32|mingw32/
      bridge = 'Ethernet'
    else
      bridge = 'eth0'
    end

    File.write('tmp/ethernet-device.txt', bridge + "\n")
  end

  if File.exist?('tmp/hostname.txt')
    hostname = File.read('tmp/hostname.txt').chomp
  else
    hostname = 'vbt'
    File.write('tmp/hostname.txt', hostname + "\n")
  end

  if File.exist?('tmp/domain.txt')
    domain = File.read('tmp/domain.txt').chomp
  else
    domain = 'example.org'
    File.write('tmp/domain.txt', domain + "\n")
  end

  c.vm.network :public_network, bridge: bridge
  c.vm.network :private_network, ip: '192.168.42.3'

  if RbConfig::CONFIG['host_os'] =~ /mswin32|mingw32/
    mount_type = 'virtualbox'
  else
    mount_type = 'nfs'
  end

  c.vm.synced_folder '.', '/vagrant', type: mount_type

  c.vm.provider :virtualbox do |v|
    v.name = 'virtual-box-tools'
    v.cpus = 2
    v.memory = 1024
  end

  c.vm.provision :shell, path: 'script/vagrant/update-system.sh'
  c.vm.provision :shell, path: 'script/vagrant/provision.sh'

  c.vm.provision :ansible do |a|
    a.playbook = 'playbook.yml'
    a.compatibility_mode = '2.0'
  end

  c.vm.synced_folder 'salt-provisioning', '/srv/salt', type: mount_type

  c.vm.provision :shell do |s|
    s.path = 'script/vagrant/salt.sh'
    s.args = [hostname + '.' + domain, '/vagrant/tmp/salt/minion.conf']

    # Install upstream Salt package.
    #s.path = 'tmp/bootstrap-salt.sh'
    # Jessie versions: https://repo.saltstack.com/apt/debian/8/amd64
    # Stretch versions: https://repo.saltstack.com/apt/debian/9/amd64
    #s.args = ['-U', '-i', hostname + '.' + domain, '-c', '/vagrant/tmp/salt', 'stable', '2018.3.3']
  end

  c.vm.provision :shell, inline: 'salt-call state.highstate'
end
