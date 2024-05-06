{ ... }:

{
  programs.git = {
    enable = true;
    userName = "lolwierd";
    userEmail = "lolwierd@outlook.com";
    extraConfig = {
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      push = {
        autoSetupRemote = "true";
      };
    };
  };
}
