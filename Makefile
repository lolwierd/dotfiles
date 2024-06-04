init-nix-oishii:
	sudo nixos-rebuild switch --flake ./nixos#oishii

init-nix-kakkoii:
	sudo nixos-rebuild switch --flake ./nixos#kakkoii

dump-dconf:
	dconf dump / | nix run nixpkgs#dconf2nix > ./nixos/home/gnome/dconf.nix
