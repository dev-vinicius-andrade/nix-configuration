{common_vars,host_vars, ...}:
{config, lib, pkgs, ... }:
let

  # Function to check if Docker is in the list of packages
  containsZsh = packages: lib.elem "zsh" packages;

  # Check if Docker is in system packages
  zshInSystemPackages = containsZsh host_vars.host.packages;

  # Check if Docker is in any user packages
  zshInUserPackages = if host_vars.users == null ||  !host_vars.users.enable || !host_vars.users.homeManager then false else   lib.any (user: containsZsh user.packages) host_vars.users.users;

  # Docker should be enabled if Docker is in system packages or any user packages
  enableZsh = zshInSystemPackages  || zshInUserPackages ;
  environmentConfig = if !enableZsh then {} else {
    environment.etc.".zshrc".source = "/home/user/.zshrc";
    environment.etc."zsh/zshenv".source = "/home/user/.zshenv";
  };
in
{
  config = lib.mkIf enableZsh {
        programs.zsh = {
            enable = true;
            enableCompletion=true;
            #enableBashCompletion=true;
            ohMyZsh= {
                enable=true;
                theme="robbyrussell";
                plugins=[
                    "fzf"
                    "golang"
                    "helm"
                    "dotnet"
                    "docker"
                    "docker-compose"
                    "emoji"
                    "eza"
                    "direnv"
                    "git"
                    "zsh-interactive-cd"
                ];
            };
        };
        inherit environmentConfig;
    };
}