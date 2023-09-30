 { config, pkgs, lib, ... }:

{
 virtualisation.virtualbox.guest = {
  	enable = true;
	  x11 = true;
  };
}
