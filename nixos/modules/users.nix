{ pkgs, ... }:

{
  users.users.lolwierd = {
    uid = 1000;
    hashedPassword = "$6$9ferZG9Rd0VX.xF9$vossOtzoH6.REKjwJmlu21sleSiCXfGvOaeRGdHazSxcUT1C5hmpd3nVawLH4QHVrjs2XjSC2NyYeNjB1fVDz0";
    description = "oishii";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
