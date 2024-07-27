{ common_vars,host_vars, ... }: { config, lib, pkgs, ... }:
let
  # Function to create program enablement attribute set
  enableProgram = program: {
    programs."${program}".enable = true;
  };

  # List of program configurations
  enabledPrograms = map enableProgram host_vars.programs;
in
{
  config = (lib.mkMerge enabledPrograms);
}