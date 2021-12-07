Vagrant.configure("2") do |config|
  config.vm.box = "generic/fedora33"
  config.vm.define "podman"

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.name = "podman"
    if Vagrant.has_plugin?("vagrant-vbguest")
      srv.vbguest.auto_update = false
    end
  end

  config.vm.provider "parallels" do |prl|
    prl.memory = 1024
    prl.name = "podman"
    prl.update_guest_tools = false
    prl.linked_clone = true
  end

  config.vm.provider :vmware_desktop do |v|
    v.vmx["memsize"] = 1024
    v.vmx["displayName"] = "podman"
    # v.ssh_info_public = true
  end

  config.vm.provider :hyperv do |h|
    # Hyper-V provider not supported ATM... exiting
  end

  config.vm.provider :docker do |d|
    # Docker provider not supported ATM... exiting
  end

  config.vm.provision "shell", inline: <<-SHELL
    dnf install -y podman

    groupadd -f -r podman

    #systemctl edit podman.socket
    mkdir -p /etc/systemd/system/podman.socket.d
    cat >/etc/systemd/system/podman.socket.d/override.conf <<EOF
[Socket]
SocketMode=0660
SocketUser=root
SocketGroup=podman
EOF
    systemctl daemon-reload
    echo "d /run/podman 0770 root podman" > /etc/tmpfiles.d/podman.conf
    systemd-tmpfiles --create

    systemctl enable podman.socket
    systemctl start podman.socket

    usermod -aG podman $SUDO_USER
  SHELL
end
