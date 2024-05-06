{ config, pkgs, lib, ... }:

{
  services.tailscale.enable = true;
  services.pcscd.enable = true;
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=1h";

  # builtin service does not work cause it starts before the graphical session. So the emacsclients cannot connect.
  systemd.user.services.emacs = {
    description = "Emacs: the extensible, self-documenting text editor";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec ${pkgs.emacs}/bin/emacs --daemon'";
      ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart = "always";
    };
    environment = {
      SSH_AUTH_SOCK = "%h/.gnupg/S.gpg-agent.ssh";
      GTK_DATA_PREFIX = config.system.path;
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
      INFOPATH = "%h/.nix-profile/info:%h/.nix-profile/share/info:/nix/var/nix/profiles/default/info:/nix/var/nix/profiles/default/share/info:/run/current-system/sw/info:/run/current-system/sw/share/info:";
      PHARO_VM = "%h/.nix-profile/bin/pharo-vm-nox";
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      NIX_CONF_DIR = "/etc/nix";
      NIX_OTHER_STORES = "/run/nix/remote-stores/*/nix";
      NIX_PATH = "nixpkgs=%h/nixpkgs:nixos=%h/nixpkgs/nixos:nixos-config=/etc/nixos/configuration.nix";
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      NIX_REMOTE = "daemon";
      NIX_USER_PROFILE_DIR = "/nix/var/nix/profiles/per-user/%u";
    };
  };
}
