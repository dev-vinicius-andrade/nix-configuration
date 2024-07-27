{common_vars,host_vars, ...}:
{ config, lib, pkgs, ... }:
let
 
  # Function to check if Docker is in the list of packages
  containsDocker = packages: lib.elem "docker" packages;
  
  # Check if Docker is in system packages
  dockerInSystemPackages = containsDocker host_vars.host.packages;
  
  # Check if Docker is in any user packages
  dockerInUserPackages = if host_vars.users == null ||  !host_vars.users.enable || !host_vars.users.homeManager then false else   lib.any (user: containsDocker user.packages) host_vars.users.users;
  
  # Docker should be enabled if Docker is in system packages or any user packages
  enableDocker = dockerInSystemPackages || dockerInUserPackages;
in
{  
  config = lib.mkIf enableDocker {
    virtualisation.docker = {
      enable = true;
      storageDriver= host_vars.docker.storageDriver;
    };
  };
}