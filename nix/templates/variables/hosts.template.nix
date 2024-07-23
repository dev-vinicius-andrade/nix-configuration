{
    host = {
        name="nixos";
        ssh = {
            enable = true;
            PermitRootLogin = "yes"; # Optional: allows root login, use with caution
            PasswordAuthentication = true; # Optional: allows password authentication
        };
        packages = [
            "zsh"
            "gnumake"
            "eza"
            "direnv"
            "gcc"
        ];
    };
    users = {
        enable = true;
        homeManager = true;
        users=[{
            name = "user";
            isNormalUser = true;
            initialPassword = "passwd";
            extraGroups = ["wheel" "networkmanager"];
            defaultShell = "zsh";
            dot_files = {
                enable = true;
                git= {
                    #url="git@github.com:dev-vinicius-andrade/dotfiles.git";
                    url="https://github.com/dev-vinicius-andrade/dotfiles.git";
                    ref="main";
                    commit_id="c06e58b7f43ec5d01508e5e0bbd71359d2ad8efd";
                };
            };
            ignoreShellProgramCheck = true;
            packages = [
                "fzf"
                "git"
                "curl"
                "starship"
                "neovim"
                "zellij"
                "nushell"
                "ripgrep"
                "jq"
                "lazygit"
            ];
        }];
    };
}