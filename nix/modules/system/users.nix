{common_vars,hosts_vars, ...}: {config, lib, pkgs, home-manager, ...}:
let
  functionsModule = import ./functions.nix { inherit config lib pkgs; };
  userConfigs = map functionsModule.functions.createUserConfig hosts_vars.users.users;
  homeManagerConfigs = map (user: functionsModule.functions.createHomeManagerConfig user common_vars.nix.version) hosts_vars.users.users;
in
{
  imports=[];
  options = {
  };
  config = lib.mkIf hosts_vars.users.enable {
    users.users = lib.mkMerge userConfigs;
    home-manager = lib.mkIf hosts_vars.users.homeManager (lib.mkMerge homeManagerConfigs);
  };
}