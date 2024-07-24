{common_vars,hosts_vars}:{config, lib, pkgs, ...}:
let 
    hostPackages = builtins.map (pkgName: pkgs.${pkgName}) hosts_vars.host.packages;
in
{
    environment.systemPackages = with pkgs; hostPackages;
}