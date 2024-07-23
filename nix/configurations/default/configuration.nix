{ config,pkgs,lib,home-manager, ... }:
let
    common_vars = import ../../variables/common.nix;
    hosts_vars= import ../../variables/hosts.nix;

in
{
    imports = [

    ];
    services.openssh=  lib.mkIf hosts_vars.host.ssh.enable {
        enable = true;
        settings = {
            PermitRootLogin = hosts_vars.host.ssh.PermitRootLogin;
            PasswordAuthentication = hosts_vars.host.ssh.PasswordAuthentication;
        };
    };
}