# Ansible roles for OpenSLX
Small collection of ansible roles to build a dracut-based initramfs for network boot via dnbd3.
Currently up-to-date versions of Ubuntu and CentOS are supported (version 18.04.1 and 7.5.1804, respectively).

The provided 'slx-builder.yml' playbook can be used, e.g. as an ansible provisioner in a packer template.
## Included roles

### slx-builder
Builds the dracut-based initramfs using the dnbd3-rootfs module (see [systemd-init](http://git.openslx.org/openslx-ng/systemd-init.git/)):
* Install needed build dependencies for the detected distribution
* Checkout git repository for systemd-init
* Build the initramfs using the 'build-initramfs.sh' script
* Extracts both initramfs and kernel to the subdirectory 'boot_files'
* Cleans up the systemd-init repository

This role is tagged to separate between the initialization of the required dependencies ('install' tag) and the build of the initramfs ('build' tag).

Depends on *setup-dev-tools* role (specified in slx-builder/meta/main.yml).

### setup-dev-tools
Installs basic development packages for the detected distribution:

    Ubuntu:		build-essential, cmake, git
    CentOS:		"@development tools", cmake, git


### disable-selinux
Disables SELinux. This is included on CentOS systems to be able to boot from the generated initramfs.
