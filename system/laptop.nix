{ config, pkgs, lib, ... }:

{
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable= true;
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-label/CRYPTED";
      preLVM = true;
    };
  }; 

  # Enable CUPS to print documents.
  services.printing.enable = true;

  systemd.services.veradecrypt = {
    wantedBy = [ "multi-user.target" ];
    description = "Decrypt veracrypt data container";
    # after = ["trousers"];
    # requires = ["trousers"];
    path = [pkgs.bash pkgs.coreutils pkgs.veracrypt pkgs.lvm2 pkgs.util-linux pkgs.ntfs3g pkgs.systemd ];
    serviceConfig = {
      Type = "oneshot";
      User = "bruh";
      RemainAfterExit = "yes";
      ExecStart = "+${pkgs.writeShellScript "decrypt-and-mount" ''
        ${pkgs.systemd}/lib/systemd/systemd-cryptsetup attach vera /dev/disk/by-partuuid/bc2897f7-2935-41a3-b6ea-6b7576988541 /home/bruh/keyfile tcrypt-veracrypt

        uid=$(id -u bruh)
        gid=$(id -g bruh)
        mount -o umask=0037,gid=$gid,uid=$uid /dev/mapper/vera /home/bruh/Shared/
      ''}";
      ExecStop = "+${pkgs.systemd}/lib/systemd/systemd-cryptsetup detach vera";
    };
  };
  
  environment.systemPackages = with pkgs; [
    veracrypt #Encryption for shared partition
  ];

} 

