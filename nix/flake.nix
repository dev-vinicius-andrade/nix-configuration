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
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko,home-manager, sops-nix, nixos-wsl,... }@inputs:

    let
      example_vars = import ./hosts/example/variables/common.nix;
      wsl_vars = import ./hosts/wsl/variables/common.nix;
    in
   {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;
    defaultPackage.x86_64-darwin = home-manager.defaultPackage.x86_64-darwin;
    nixosConfigurations = {
        example = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          system = example_vars.system;
          modules = [
            disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops        
            ./disko/default/disko.nix
            ./hosts/example/hardware-configuration.nix
            ./hosts/example/configuration.nix          
          ];
        };
        wsl = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          system = wsl_vars.system;
          modules = [
            nixos-wsl.nixosModules.default
            ./hosts/wsl/configuration.nix 
          ];
        };
        # "${host}" = nixpkgs.lib.nixosSystem {
        #   specialArgs = {inherit inputs;};
        #   system = defaultSystem;
        #   modules = [
        #     disko.nixosModules.disko
        #     inputs.home-manager.nixosModules.default
        #     home-manager.nixosModules.home-manager
        #     sops-nix.nixosModules.sops
        #     disko_config        
        #     ./hosts/${host}/configuration.nix          
        #   ];
        # };
      };
  };
}