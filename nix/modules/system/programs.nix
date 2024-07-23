{ common_vars,hosts_vars, ... }: { config, lib, pkgs, ... }:
let
  # Function to create program enablement attribute set
  enableProgram = program: {
    programs."${program}".enable = true;
  };

  # List of program configurations
  enabledPrograms = map enableProgram hosts_vars.programs;
in
{
  config = (lib.mkMerge enabledPrograms);
}