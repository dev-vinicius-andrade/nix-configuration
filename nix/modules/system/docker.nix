{ config, lib, pkgs, ... }:

let
  hosts_vars = config.hosts_vars;
  
  # Function to check if Docker is in the list of packages
  containsDocker = packages: lib.elem "docker" packages;
  
  # Check if Docker is in system packages
  dockerInSystemPackages = containsDocker hosts_vars.packages;
  
  # Check if Docker is in any user packages
  dockerInUserPackages = lib.any (user: containsDocker user.packages) hosts_vars.users;
  
  # Docker should be enabled if Docker is in system packages or any user packages
  enableDocker = dockerInSystemPackages || dockerInUserPackages;
in
{
  options = {
    hosts_vars = lib.mkOption {
      type = lib.types.attrs;
      description = "Host-specific variables";
    };
  };
  
  config = lib.mkIf enableDocker {
    services.docker = {
      enable = true;
      package = pkgs.docker;
    };
    # Apply additional Docker configuration from hosts_vars.docker.configuration
    services.docker = lib.mkMerge [
      config.services.docker
      hosts_vars.docker.configuration
    ];
  };
}