{common_vars,host_vars, ...}: {config, lib, pkgs, ...}:
{
    networking = lib.mkIf !host_vars.host.isWsl {
        hostName = host_vars.host.name;
    };
}


