{ config, pkgs, ... }:

{
  imports = [
    ./emacs.nix
  ]

  services.tailscale.enable = true;

  # IDK if this even works.
  # services.pcscd.enable = true;
  # services.logind = {
  #   lidSwitch = "suspend-then-hibernate";
  #   extraConfig = ''
  #     HandlePowerKey=suspend-then-hibernate
  #     IdleAction=suspend-then-hibernate
  #     IdleActionSec=2m
  #   '';
  # };
  # systemd.sleep.extraConfig = "HibernateDelaySec=1h";

}
