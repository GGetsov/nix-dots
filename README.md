# nix-dots
My nixos/home-manager config

## Installation guide
This guide is mainly for me to remind myself how to do this again. That being said it also should help anybody who wants to recreate my setup. The configuration i have choisen is a NixOS installation using LVM on top of LUKS partition, having 2 ext4 partitions (root and home) and a swap partition.

### Bootable USB (skip if on VM)
Start with creating a bootable USB using a tool like [Rufus](https://rufus.ie/en/) or [Ventoy](https://www.ventoy.net/en/index.html). Any of the 3 [NixOS ISO images](https://nixos.org/download) can be used (Minimal/KDE/Gnome), but the whole guide can be completed inside a tty the recomended way is to use the minimal iso. Once created boot into from the USB.

### Optional
#### Login as root
Most of the following commands will require root privileges so rather than using `sudo` before most of the commands loging as root using `sudo su` will save some typing.
#### Terminal font
Normally the tty font is hard to read, so you can use the "setfont" command to choose a better sized font:
`setfont ter-128n`
#### WiFi
Ethernet should work out of the box, but WiFi should be connected manually. To do this first execute `iwconfig` in order to list wireless interfaces (for example `wlp8s0`). Then using `iwlist wlp8s0 scan | grep ESSID` (replace `wlp8s0` with the name of your wireless interface) will list all the available WiFi networks (`ESSID` meaning the name of the network). To connect to one of the networks (for example one with name `my wifi` and password `12345678`) first configure wpa_supplicant using `wpa_passphrase 'my wifi' 12345678 > /etc/wpa_supplicant.conf`, then execute `sudo wpa_supplicant -B -c /etc/wpa_supplicant.conf -i wlp8s0`.  To test if connected properly use `ping google.com`.

### Partitioning and Encryption
List all disks using `lsblk -f`. Pick one of the disks (for example `/dev/sda1`) on which to install NixOS and use `gdisk /dev/sda` to create partition the drive:
- `o` will create new empty partition table
- `n` will create new partition
	- first one (boot partition) should be of size 1G (This big because the original plymouth's theme creator states it is required to function properly, but i have tested with 500M so choose at your own risk) and with type ef00.
	second one (LVM) should use the rest of the disk and be of type 8300
- `w` will write partition table and exit

Setup the encrypted LUKS partition and open it:

	cryptsetup luksFormat /dev/sda2
	cryptsetup luksOpen /dev/sda2 crypted
	cryptsetup config /dev/sda2 --label CRYPTED

Then create 3 logical partitions (16G swap and 2 split equally root and home);

	pvcreate /dev/mapper/crypted
	vgcreate vg /dev/mapper/crypted
	lvcreate -L 8G -n swap vg
	lvcreate -l '50%FREE' -n root vg
	lvcreate -l '100%FREE' -n home vg

 
### Format disks
	mkfs.fat -F 32 -n BOOT /dev/sda1
	mkfs.ext4 -L ROOT /dev/vg/root
	mkfs.ext4 -L HOME /dev/vg/home
	mkswap -L SWAP /dev/vg/swap

### Mount

	mount /dev/disk/by-label/ROOT /mnt
	mkdir /mnt/boot
	mkdir /mnt/home
	mount /dev/disk/by-label/BOOT /mnt/boot
	mount /dev/disk/by-label/HOME /mnt/home
	swapon /dev/vg/swap

### Configure and Install
Generate config using `nixos-generate-config --root /mnt` and then `cd /mnt/etc/nixos`. Install git using `nix-shell -p git` and clone the repository `git clone https://github.com/ggetsov/nix-dots.git`. Copy the hardware configuration file inside the nix-dots/system directory (`cp hardware-configuration.nix nix-dots/system/`), enter the directory `cd nix-dots` and add it to git repo using `git add -f system/hardware-configuration.nix`. Install the nixos configuration using `nixos-install --flake ./system/#{machine}`, where `{machine}` is the specific machine configuration (for now `laptop` or `vm`). After install `passwd bruh` and `reboot`.

### Home-manager
After reboot 
    mv /etc/nixos/nix-dots .
    chown -R bruh:users nix-dots
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --update
    home-manager switch -f nix-dots/user/home.nix
