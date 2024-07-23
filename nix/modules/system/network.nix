{common_vars,hosts_vars, ...}: {config, lib, pkgs, ...}:
{
    networking.hostName = hosts_vars.host.name;
}


