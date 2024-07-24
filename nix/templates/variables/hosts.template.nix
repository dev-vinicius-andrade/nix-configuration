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
                    commit_id="d0132963d81d3c9747b9021a49039fb7cc12ac76";
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
                "nodejs"
            ];
        }];
    };
    docker= {};
}