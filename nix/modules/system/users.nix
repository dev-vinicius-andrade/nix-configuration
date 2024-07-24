{common_vars,hosts_vars, ...}: {config, lib, pkgs, home-manager, ...}:
let
  createUserConfig = user: {
    "${user.name}" = {
      isNormalUser = user.isNormalUser;
      initialPassword = user.initialPassword;
      extraGroups = user.extraGroups;
      home = "/home/${user.name}";
      shell = builtins.getAttr user.defaultShell pkgs;
      createHome = true;
      ignoreShellProgramCheck= user.ignoreShellProgramCheck;
    };
  };
  # createProgramConfig = program: {
  #   "${program}".enable = true;
  # };
  copyFiles = src: dest: ''
    mkdir -p ${dest}
    cp -r ${src}/* ${dest}
  '';

   getDotFiles = user: 
     if !user.dot_files.enable || user.dot_files.git==null || user.dot_files.git.url == "" then 
       null 
     else 
      builtins.fetchGit {
        url = user.dot_files.git.url;
        ref= user.dot_files.git.ref;
        rev = user.dot_files.git.commit_id;
      };
  createSymlink = user: src: dest: ''
    ln -sfn ${src} ${dest}
    echo "Created symlink from ${src} to ${dest}" >> /home/${user.name}/debug.log
  '';
  createHomeManagerConfig = user:
  let 
    dotfiles = getDotFiles user;
    writableDotfiles = "/home/${user.name}/dotfiles";
  in
  {
    
    users."${user.name}" = {
      home = {
        homeDirectory = "/home/${user.name}";
        stateVersion = common_vars.nix.version;
        packages = with pkgs; map (program: pkgs.${program}) user.packages;
        activation = {
          postActivate  = ''
            if [ -n "${dotfiles}" ]; then
              echo "Dotfiles are not null" >> /home/${user.name}/debug.log
              if [ ! -d "${writableDotfiles}" ]; then
                echo "Creating writable dotfiles directory" >> /home/${user.name}/debug.log
                mkdir -p "${writableDotfiles}"
              fi

              echo "Copying dotfiles to ${writableDotfiles}" >> /home/${user.name}/debug.log
              cp -r ${dotfiles}/. ${writableDotfiles}
              echo "Giving permission to write  dotfiles to ${writableDotfiles}" >> /home/${user.name}/debug.log
              chmod -R 777 ${writableDotfiles}
              echo "Creating symlinks" >> /home/${user.name}/debug.log
              ${createSymlink user "${writableDotfiles}/.zshrc" "/home/${user.name}/.zshrc"}
              ${createSymlink user "${writableDotfiles}/nvim" "/home/${user.name}/.config/nvim"}
              ${createSymlink user "${writableDotfiles}/nvim" "/home/${user.name}/.config/nvim"}
              ${createSymlink user "${writableDotfiles}/starship" "/home/${user.name}/.config/starship"}
              ${createSymlink user "${writableDotfiles}/nushell" "/home/${user.name}/.config/nushell"}
              ${createSymlink user "${writableDotfiles}/zellij" "/home/${user.name}/.config/zellij"}
            else
              echo "Dotfiles are null" >> /home/${user.name}/debug.log
            fi
          '';
        };
      };
    };
  };

  userConfigs = map createUserConfig hosts_vars.users.users;
  homeManagerConfigs = map (user: createHomeManagerConfig user) hosts_vars.users.users;
in
{
  imports=[];
  options = {
  };
  config = lib.mkIf hosts_vars.users.enable {
    users.users = lib.mkMerge userConfigs;
    home-manager = lib.mkIf hosts_vars.users.homeManager (lib.mkMerge homeManagerConfigs);
  };
}