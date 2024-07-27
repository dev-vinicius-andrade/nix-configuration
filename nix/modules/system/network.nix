{common_vars,host_vars, ...}: {config, lib, pkgs, ...}:
let
    enableNetworking = !host_vars.host.isWsl;
in 
{
    networking = lib.mkIf enableNetworking  {
        hostName = host_vars.host.name;
    };
}


