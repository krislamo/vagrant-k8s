CPU = 2
MEM = 2048

HOSTS = Array(1..3)
Vagrant.configure(2) do |vm_config|

  HOSTS.each do |count|
    vm_config.vm.define "node".concat("#{count}") do |config|
      config.vm.box = "debian/bullseye64"
      config.vm.network "private_network", type: "dhcp"
      config.vm.hostname = "node".concat("#{count}")
      config.vm.synced_folder ".", "/vagrant", type: "rsync",
        rsync__exclude: [".git/", "*.log"]

      # Libvirt
      config.vm.provider :libvirt do |virt|
        virt.memory = MEM
        virt.cpus = CPU
      end

      # VirtualBox
      config.vm.provider :virtualbox do |vbox|
        vbox.memory = MEM
        vbox.cpus = CPU
      end

      config.vm.provision "shell", path: "scripts/provision.sh"
    end
  end
end
