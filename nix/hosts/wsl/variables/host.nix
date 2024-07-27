{
    host = {
        name="nixos";
        isWsl = true;
        packages = [
            "zsh"
            "gnumake"
            "eza"
            "direnv"
            "gcc"
            "xclip"
        ];
    };
    users = {
        enable = true;
        homeManager = true;
        users=[{
            name = "nixos";
            isNormalUser = true;
            extraGroups = ["wheel" "networkmanager"];
            initialPassword = null;
            defaultShell = "zsh";
            dot_files = {
                enable = true;
                path = "/mnt/f/repos/github/dev-vinicius-andrade/dotfiles";
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
    docker= {
        storageDriver=null;
    };
}