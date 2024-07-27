{common_vars,host_vars, ...}: {config, lib, pkgs, home-manager, ...}:
let
  functionsModule = (import ./functions.nix {inherit common_vars host_vars;} { inherit config lib pkgs; });
  userConfigs = map functionsModule.functions.createUserConfig host_vars.users.users;
  homeManagerConfigs = map (user: functionsModule.functions.createHomeManagerConfig user common_vars.nix.version) host_vars.users.users;
in
{
  imports=[];
  options = {
  };
  config = lib.mkIf host_vars.users.enable {
    users.users = lib.mkMerge userConfigs;
    home-manager = lib.mkIf host_vars.users.homeManager (lib.mkMerge homeManagerConfigs);
  };
}