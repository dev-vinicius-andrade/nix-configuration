{}:{
    config = {
        programs.zsh = {
            enable = true;
            enableCompletion=true;
            enableBashCompletion=true;
            ohMyZsh= {
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
        };
    };
}
