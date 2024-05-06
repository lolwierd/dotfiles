# dotfiles

https://www.gnu.org/software/stow/

~~using sudo mount --bind /etc/nixos/ ./nixos for now. doesn't feel right but works~~
~~BETTER: sudo ln -s (pwd)/nixos/configuration.nix /etc/nixos/configuration.nix~~

just run ```nsu```. 

~~After manually copying and building the config first ofc.~~

~~Simlinking/stow does not work maybe cause of flakes. -I does not work. getting into the dir and just --flakes . does not work.~~

~~At this point idc. ill just copy the files the first time i setup a new nixos machine :).~~

```make link``` to stow nvim, kitty, doom config. zsh and tmux managed by nix.


```
For flakes in git repos, only files in the working tree will be copied to the store.
Therefore, if you use git for your flake, ensure to git add any project files after you first create them.
```
mb og.

```nixos-rebuild switch --flake ~/dotfiles/nixos```
