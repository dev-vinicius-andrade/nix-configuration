{common_vars,hosts_vars, ...}:
{ config, lib, pkgs, ... }:
let
 
  # Function to check if Docker is in the list of packages
  containsDocker = packages: lib.elem "docker" packages;
  
  # Check if Docker is in system packages
  dockerInSystemPackages = containsDocker hosts_vars.packages;
  
  # Check if Docker is in any user packages
  dockerInUserPackages = if hosts_vars.users == null ||  !hosts_vars.users.enable || !hosts_vars.users.homeManager then false else   lib.any (user: containsDocker user.packages) hosts_vars.users.users;
  
  # Docker should be enabled if Docker is in system packages or any user packages
  enableDocker = dockerInSystemPackages || dockerInUserPackages;
in
{  
  config = lib.mkIf enableDocker {
    virtualisation.docker = {
      enable = true;
      storageDriver= hosts_vars.docker.storageDriver;
    }
  };
}