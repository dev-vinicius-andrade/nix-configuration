{common_vars,hosts_vars, ...}:
{config,lib,pkgs,...}:{
    config={
        fonts.packages= with pkgs;[
            (nerdfonts.override {fonts=["JetBrainsMono" "Hack" "Terminus" "NerdFontsSymbolsOnly"];})
        ];
    };
}