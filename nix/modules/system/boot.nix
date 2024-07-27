{common_vars,host_vars}:{config, lib, pkgs, ...}:
{
    boot.loader= {
        grub = {
            enable = true;
            devices=[config.disko.devices.disk.one.device];
            useOSProber = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
        };
    };
}