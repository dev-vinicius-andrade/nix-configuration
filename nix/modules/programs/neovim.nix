{common_vars,host_vars, ...}:{config,pkgs,self,...}:{
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
