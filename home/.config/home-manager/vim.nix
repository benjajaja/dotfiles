{ config, pkgs, lib, vimUtils, ... }:

let
  easyclip = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "easyclip";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "svermeulen";
      repo = "vim-easyclip";
      rev = "f1a3b95463402b30dd1e22dae7d0b6ea858db2df";
      sha256 = "sha256-KBHC95cswqsQinMze/nlI43WZkXMXrDuTfK3z4hHYPg=";
    };
  };
  # sidebar-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    # pname = "sidebar-nvim";
    # version = "2023-03-17";
    # src =  pkgs.fetchFromGitHub {
      # owner = "sidebar-nvim";
      # repo = "sidebar.nvim";
      # rev = "990ce5f562c9125283ccac5473235b1a56fea6dc";
      # sha256 = "sha256-/6q/W7fWXlJ2B9o4v+0gg2QjhzRC/Iws+Ez6yyL1bqI=";
    # };
  # };
  nebulous-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nebulous-nvim";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "Yagua";
      repo = "nebulous.nvim";
      rev = "fe4562b2b0a18ec1e439f515a659d5f4dd16ecd3";
      sha256 = "sha256-88xkhhVVpWHCMBfUcUgYshHm+OM5yjMnqwNtsUV21No=";
    };
  };
  midnight-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "midnight-nvim";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "dasupradyumna";
      repo = "midnight.nvim";
      rev = "3e6e5b9c950c785a79f9b0d5d9cdc5096ec87057";
      sha256 = "sha256-NmBQty0TweUhmERFu/tf0nmAydr1UujAbIkijyixnec=";
    };
  };
  nightvision-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nightvision-nvim";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "mathofprimes";
      repo = "nightvision-nvim";
      rev = "8b28cc9907256ff3761495aca3a9bb4e32c892b2";
      sha256 = "sha256-LI3QdX0Rc8XTqnP972ev1i0xA4uTUfleScbzRL/eA/M=";
    };
  };

  vimrc = builtins.readFile ./vimrc;
  lsp_lua = builtins.readFile ./lsp.lua;
  cmp_lua = builtins.readFile ./cmp.lua;
  nvim_lua = builtins.readFile ./nvim.lua;
in {
  programs = {
    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        nvim-web-devicons
        # barbar-nvim
        bufferline-nvim
        bufdelete-nvim
        vim-repeat
        easyclip
        vim-surround
        nerdcommenter
        camelcasemotion
        # sidebar-nvim
        # neo-tree-nvim

        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        nvim-cmp
        cmp-vsnip
        vim-vsnip
        telescope-nvim
        telescope-zf-native-nvim
        nvim-lsputils
        nvim-treesitter.withAllGrammars
        cmp-treesitter
        rust-tools-nvim
        vim-illuminate
        persistence-nvim

        plenary-nvim
        null-ls-nvim
        typescript-nvim

        tokyonight-nvim
        dracula-nvim
        kanagawa-nvim
        catppuccin-nvim
        midnight-nvim
        nightvision-nvim
        nebulous-nvim
        awesome-vim-colorschemes
        changeColorScheme-vim
      ];
      extraConfig = ''
${vimrc}
lua << EOF
${cmp_lua}
${lsp_lua}
${nvim_lua}
EOF
      '';
    };
  };

}

