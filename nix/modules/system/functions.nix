{common_vars,host_vars, ...}:{config, lib, pkgs, ...}:
let
 functions = rec {
        containsPackage = package: packages: lib.elem package packages;
        # Check if Docker is in system packages
        packageInSystemPackages = package: containsPackage package host_vars.host.packages;

        # Check if Docker is in any user packages
        packageInUserPackages = package:  if host_vars.users == null ||  !host_vars.users.enable || !host_vars.users.homeManager then false else   lib.any (user: containsPackage package user.packages) host_vars.users.users;

        # Docker should be enabled if Docker is in system packages or any user packages
        isPackageEnabled = package: (packageInSystemPackages package)  || (packageInUserPackages package) ;
        copyFiles = src: dest: ''
            mkdir -p ${dest}
            cp -r ${src}/* ${dest}
        '';
        isWsl = host_vars.host.isWsl;
        getDotFiles = user:
        if !user.dot_files.enable then
            null
        else if user.dot_files.path != null && user.dot_files.path != "" then
            user.dot_files.path
        else if user.dot_files.git != null && user.dot_files.git.url != "" then
            builtins.fetchGit {
            url = user.dot_files.git.url;
            ref = user.dot_files.git.ref;
            rev = user.dot_files.git.commit_id;
            }
        else
            null;
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
            initialPassword = if isWsl then null else user.initialPassword;
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
                            if [ "${toString isWsl}" = "1" ]; then
                                echo "Creating symlinks for dotfiles in WSL" >> /home/${user.name}/debug.log
                                ${functions.createSymlink user "${dotfiles}" "${writableDotfiles}"}

                                if [ -d "$HOST_HOME/.ssh"]; then
                                      ${functions.createSymlink user "$HOST_HOME/.ssh" "~/.ssh"}
                                fi
                            else
                                if [ ! -d "${writableDotfiles}" ]; then
                                    echo "Creating writable dotfiles directory" >> /home/${user.name}/debug.log
                                    mkdir -p "${writableDotfiles}"
                                fi
                                echo "Copying dotfiles to ${writableDotfiles}" >> /home/${user.name}/debug.log
                                cp -r ${dotfiles}/. ${writableDotfiles}
                                echo "Giving permission to write dotfiles to ${writableDotfiles}" >> /home/${user.name}/debug.log
                                ${functions.giveOwnership user "${writableDotfiles}"}
                                ${functions.giveAllPermissions "${writableDotfiles}"}
                                ${functions.giveAllPermissions "/home/${user.name}/.local/share/nvim"}
                                ${functions.giveAllPermissions "/home/${user.name}/.local/state/nvim"}
                                echo "Creating symlinks" >> /home/${user.name}/debug.log
                            fi
                            
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
                programs= {
                    zsh = if isPackageEnabled "zsh" then {
                        enable = true;
                        enableCompletion=true;
                        autosuggestion.enable=true;
                        history.expireDuplicatesFirst=true;
                        syntaxHighlighting.enable=true;
                        #dotDir= ".config/zsh-custom";
                        oh-my-zsh= {
                            enable=true;
                            theme="robbyrussell";
                            plugins=[
                                "fzf"
                                "golang"
                                "helm"
                                "dotnet"
                                "docker"
                                "docker-compose"
                                "emoji"
                                "eza"
                                "direnv"
                                "git"
                                "zsh-interactive-cd"
                            ];
                        };
                        initExtra=''
                            REAL_ZSHRC_PATH=$(readlink -f /home/${user.name}/dotfiles/.zshrc)
                            if [[ -f "$REAL_ZSHRC_PATH" ]]; then
                                source "$REAL_ZSHRC_PATH"
                            fi
                        '';
                    } else {
                        enable = false;
                    };
                };
            };
        };
    };
in
{
    inherit functions;
}