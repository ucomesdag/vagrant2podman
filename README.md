# vagrant2podman
Easily run [Podman][podman] on **MacOS** using [Vagrant][vagrant], [VirtualBox][virtualbox] (or [VMware Fusion][vmware], or [Parallels Desktop Pro][parallels]) and the [podman-remote][podman-remote] command. 

Previously there was
[podman-machine](https://github.com/boot2podman/machine) that used [boot2podman](https://github.com/boot2podman/boot2podman), a lightweight Linux distribution made specifically to run Linux containers on MacOS and VirtualBox, but that has sadly been deprecated since.

Using Vagrant is proposed as an alternative.  

In this repository you will find a Vagrantfile to setup a [Fedora][fedora] virtual machine with podman installed. It is accompanied by an install script that will install the `podman-vagrant` command for managing the podman machine via vagrant. This command is a simple wrapper script that interacts with vagrant.

```
% podman-vagrant
Usage:    podman-vagrant COMMAND [arg...]

Commands:
  start             starts and provisions the podman vagrant environment
  stop              suspends the podman machine
  env               display the commands to set up the environment for podman
  ip                display the ip of the podman machine
  ssh               connects to the podman machine via SSH
  ssh-config        outputs SSH configuration to connect to the podman machine
  scp               copies data into the podman machine via SCP
  status            outputs status of the podman machine
  destroy           stops and deletes all traces of the podman vagrant machine
  uninstall         remove this podman-vagrant command
```

## Requirements
+ [VirtualBox][virtualbox] (or [VMware Fusion][vmware], or [Parallels Desktop Pro][parallels])
+ [Vagrant][vagrant]
+ [podman-remote][podman-remote] <sup>[1](#footnote1)</sup>

<sup><a name="footnote1">1</a>: You can install podman(-remote) with [Brew][brew] or [MacPorts][macports].</sup>

## Usage
First clone this repository on your local machine and run the install script in the cloned repository. This will install the `podman-vagrant` command for managing your podman machine in your PATH.

```
cd vagrant2podman/
bash install.sh
```

Next create and provision the Fedora virtual machine with podman by running `podman-vagrant start`.

After the virtual machine is created and up and running, run `podman-vagrant env` and follow the instruction to set your environment to make `podman-remote` use the podman machine.

Now the command `podman-remote info` should return something like the following:

```
host:
  arch: amd64
  buildahVersion: 1.18.0
  cgroupManager: systemd
  cgroupVersion: v2
  conmon:
    package: conmon-2.0.26-1.fc32.x86_64
    path: /usr/bin/conmon
    version: 'conmon version 2.0.26, commit: 74feb474bea20d593dfb70e1e244893b9eb6b619'
  cpus: 1
  distribution:
    distribution: fedora
    version: "32"
    
...output omitted...
    
```    

## Example
```
% podman-vagrant start
Bringing machine 'podman' up with 'virtualbox' provider...
==> podman: Checking if box 'fedora/33-cloud-base' version '33.20201019.0' is up to date...

...output omitted...
 
% eval $(podman-vagrant env)
% podman run -d --name webserver -p 8080:80 httpd
Trying to pull docker.io/library/httpd:latest...
Getting image source signatures
Copying blob sha256:d1589b6d8645a965434e869bd0adc4586480294e7cd62477c94357ef11c6ce10

...output omitted...

% curl $(podman-vagrant ip):8080
<html><body><h1>It works!</h1></body></html>
```

[virtualbox]: https://www.virtualbox.org
[vmware]: https://my.vmware.com/group/vmware/evalcenter?p=fusion-player-personal
[parallels]: https://www.parallels.com/eu/products/desktop/pro/
[vagrant]: https://www.vagrantup.com/downloads
[podman-remote]: https://podman.io/getting-started/installation
[podman]: https://podman.io
[brew]: https://brew.sh
[macports]: https://www.macports.org
[fedora]: https://getfedora.org
