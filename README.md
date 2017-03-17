# Ansible roles for OpenSLX
Small collection of ansible roles to build a dracut-based initramfs for network boot.
The roles currently support both Ubuntu 16.04.2 and CentOS 7.3.
Currently, it only matches these distribution families but does not check for these exact versions!

### setup-dev-tools
Installs basic development packages for the detected distribution:

    Ubuntu:		build-essential, cmake, git
    CentOS:		"@development tools", cmake, git

### dracut-initramfs-builder
Builds the dracut-based initramfs using the dnbd3-rootfs module (see [systemd-init](http://git.openslx.org/openslx-ng/systemd-init.git/)):
* Install needed dependencies to build dracut for the detected distribution
* Checkout git repository for systemd-init
* Build the initramfs for the running kernel
* Extract both initramfs and kernel out of the virtual machine

Depends on *setup-dev-tools* role (see dracut-initramfs-builder/meta/main.yml).

## Usage
Use the provided 'build-dracut-initramfs.yml' playbook for the ansible provisioner in your packer template.
