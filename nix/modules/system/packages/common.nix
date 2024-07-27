{common_vars,host_vars}:{config, lib, pkgs, ...}:
let 
    hostPackages = builtins.map (pkgName: pkgs.${pkgName}) host_vars.host.packages;
in
{
    environment.systemPackages = with pkgs; hostPackages;
}