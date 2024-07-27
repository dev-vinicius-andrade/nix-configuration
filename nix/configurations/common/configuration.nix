{common_vars,host_vars}:{ config,pkgs,lib,home-manager, ... }:
{
    # Enable Flakes and Nix Command
    nix.settings.experimental-features = ["nix-command" "flakes"];
    imports = [
        (import ../../modules/system/boot.nix {common_vars = common_vars; host_vars=host_vars;})
        (import ../../modules/system/network.nix {common_vars = common_vars; host_vars=host_vars;})
        (import ../../modules/system/users.nix {common_vars = common_vars; host_vars=host_vars;})
        (import ../../modules/system/fonts.nix {common_vars = common_vars; host_vars=host_vars;})
        (import ../../modules/system/docker.nix {common_vars = common_vars; host_vars=host_vars;})
        (import ../../modules/system/packages/common.nix {common_vars = common_vars; host_vars=host_vars;})
    ];
    time.timeZone = common_vars.timeZone;
    console.keyMap = common_vars.keyMap;
    console.font = common_vars.font;
    system.stateVersion = common_vars.nix.version;
}