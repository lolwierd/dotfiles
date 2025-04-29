{ config, pkgs, ... }:

{

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

  services.caddy = {
    enable = true;
    configFile = "/etc/caddy/Caddyfile";
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.1" ];
      hash = "sha256-saKJatiBZ4775IV2C5JLOmZ4BwHKFtRZan94aS5pO90=";
    };
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = "/etc/caddy/env";
}
