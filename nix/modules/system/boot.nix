{common_vars,host_vars}:{config, lib, pkgs, ...}:
let
    enableBoot = !host_vars.host.isWsl;
in 
{
    boot.loader= {
        grub = lib.mkIf enableBoot {
            enable = true;
            devices=[config.disko.devices.disk.one.device];
            useOSProber = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
        };
    };
}