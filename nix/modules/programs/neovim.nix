{common_vars,hosts_vars, ...}:{config,pkgs,self,...}:{
    config = {
        programs.neovim = 
         {
            enable = true;
            viAlias = true;
            vimAlias = true;
            vimdiffAlias = true;
        };
    };
}
