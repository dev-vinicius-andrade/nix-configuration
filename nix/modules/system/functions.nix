{config, lib, pkgs, ...}:
let
 functions = rec {
        copyFiles = src: dest: ''
            mkdir -p ${dest}
            cp -r ${src}/* ${dest}
        '';

        getDotFiles = user:
            if !user.dot_files.enable || user.dot_files.git == null || user.dot_files.git.url == "" then 
            null 
            else 
            builtins.fetchGit {
                url = user.dot_files.git.url;
                ref = user.dot_files.git.ref;
                rev = user.dot_files.git.commit_id;
            };

        createSymlink = user: src: dest: ''
            ln -sfn ${src} ${dest}
            echo "Created symlink from ${src} to ${dest}" >> /home/${user.name}/debug.log
        '';

        ensureDirectoryExists = dir: ''
            if [ ! -d "${dir}" ]; then
            mkdir -p ${dir}
            fi
        '';

        giveOwnership = user: dir: ''
            ${functions.ensureDirectoryExists dir}
            chown -R ${user.name} ${dir}
        '';

        giveAllPermissions = dir: ''
            ${functions.ensureDirectoryExists dir}
            chmod -R 777 ${dir}
        '';

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
        createHomeManagerConfig = user: stateVersion:
        let 
            dotfiles = functions.getDotFiles user;
            writableDotfiles = "/home/${user.name}/dotfiles";
        in
        {
            
            users."${user.name}" = {
            home = {
                homeDirectory = "/home/${user.name}";
                stateVersion = stateVersion;
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
                    ${functions.giveOwnership user "${writableDotfiles}"}
                    ${functions.giveAllPermissions "${writableDotfiles}"}
                    ${functions.giveAllPermissions "/home/${user.name}/.local/share/nvim"}
                    ${functions.giveAllPermissions "/home/${user.name}/.local/state/nvim"}
                    echo "Creating symlinks" >> /home/${user.name}/debug.log
                    ${functions.createSymlink user "${writableDotfiles}/.zshrc" "/home/${user.name}/.zshrc"}
                    ${functions.createSymlink user "${writableDotfiles}/nvim" "/home/${user.name}/.config/nvim"}
                    ${functions.createSymlink user "${writableDotfiles}/nvim" "/home/${user.name}/.config/nvim"}
                    ${functions.createSymlink user "${writableDotfiles}/starship" "/home/${user.name}/.config/starship"}
                    ${functions.createSymlink user "${writableDotfiles}/nushell" "/home/${user.name}/.config/nushell"}
                    ${functions.createSymlink user "${writableDotfiles}/zellij" "/home/${user.name}/.config/zellij"}
                    else
                    echo "Dotfiles are null" >> /home/${user.name}/debug.log
                    fi
                '';
                };
            };
            };
        };
    };
in
{
    inherit functions;
}