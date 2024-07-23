{
  description = "Default flake and disko";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko,home-manager, sops-nix ,... }@inputs:

    let 
      common_vars = import ./variables/common.nix;
      hosts_vars= import ./variables/hosts.nix;
      defaultSystem = common_vars.system;
    in
   {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    defaultPackage.x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        system = defaultSystem;
        modules = [
          disko.nixosModules.disko
          inputs.home-manager.nixosModules.default
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops        
          ./hardware-configuration.nix
          ./disko/default/disko.nix
          ./configurations/common/configuration.nix
          ./configurations/default/configuration.nix          
        ];
      };
    };
  };
}