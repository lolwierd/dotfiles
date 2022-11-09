if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Initialize zoxide
zoxide init fish | source

direnv hook fish | source

function nixify 
  if ! test -e ./.envrc
    echo "use nix" > .envrc
    direnv allow
  end
  if ! test -e shell.nix && ! test -e default.nix
    echo -e "with import <nixpkgs> {};\nmkShell { \n  nativeBuildInputs = [\n     bashInteractive \n   ];\n}" > shell.nix
    vi default.nix
  end
end

function flakify
  if ! test -e flake.nix
    nix flake new -t github:nix-community/nix-direnv .
  else if ! test -e .envrc
    echo "use flake" > .envrc
    direnv allow
  end
  vi flake.nix
end
