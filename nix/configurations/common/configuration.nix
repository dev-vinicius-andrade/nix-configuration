{ config,pkgs,lib,home-manager, ... }:
let
    common_vars = import ../../variables/common.nix;
    hosts_vars= import ../../variables/hosts.nix;
in
{
    # Enable Flakes and Nix Command
    nix.settings.experimental-features = ["nix-command" "flakes"];
    imports = [
        (import ../../modules/system/boot.nix {common_vars = common_vars; hosts_vars=hosts_vars;})
        (import ../../modules/system/network.nix {common_vars = common_vars; hosts_vars=hosts_vars;})
        (import ../../modules/system/users.nix {common_vars = common_vars; hosts_vars=hosts_vars;})
        # (import ../../modules/system/programs.nix {common_vars = common_vars; hosts_vars=hosts_vars;})
        (import ../../modules/system/fonts.nix {common_vars = common_vars; hosts_vars=hosts_vars;})
        (import ../../modules/system/packages/common.nix {common_vars = common_vars; hosts_vars=hosts_vars;})
    ];
    time.timeZone = common_vars.timeZone;
    console.keyMap = common_vars.keyMap;
    console.font = common_vars.font;
    system.stateVersion = common_vars.nix.version;
}