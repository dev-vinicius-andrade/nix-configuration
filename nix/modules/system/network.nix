{common_vars,host_vars, ...}: {config, lib, pkgs, ...}:
{
    networking.hostName = host_vars.host.name;
}


