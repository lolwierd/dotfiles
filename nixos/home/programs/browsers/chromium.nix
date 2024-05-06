{ config, pkgs, ... }:

{
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    # Extensions do not work with ungoogled-chromium
    # extensions = [
      # { id = "nngceckbapebfimnlniiiahkandclblb"; } #Bitwarden
      # { id = "kekjfbackdeiabghhcdklcdoekaanoel"; } #MAL-Sync
      # { id = "cimiefiiaegbelhefglklhhakcgmhkai"; } #Plasma Browser Integration
      # { id = "ldgfbffkinooeloadekpmfoklnobpien"; } #Raindrop.io
      # { id = "mnjggcdmjocbbbhaepdhchncahnbgone"; } #Sponsorblock
      # { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } #uBlock Origin
      # { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } #Vimium
    # ];
  };
}
