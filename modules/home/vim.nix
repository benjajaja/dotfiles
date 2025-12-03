{ config, pkgs, lib, vimUtils, ... }:

let
  cutlass = pkgs.vimUtils.buildVimPlugin {
    pname = "vim-cutlass";
    version = "2020-03-01";
    src =  pkgs.fetchFromGitHub {
      owner = "svermeulen";
      repo = "vim-cutlass";
      rev = "7afd649415541634c8ce317fafbc31cd19d57589";
      sha256 = "sha256-j5W9q905ApDf3fvCIS4UwyHYnEZu5Ictn+6JkV/xjig=";
    };
  };
  sectional-couch = pkgs.vimUtils.buildVimPlugin {
    pname = "sectional-couch";
    version = "2024-08-29";
    src =  pkgs.fetchFromGitHub {
      owner = "Boolean263";
      repo = "sectional-couch.vim";
      rev = "6e5128c754871ec8496607a5a268b651c8a70f23";
      sha256 = "sha256-9lvAVNwzFyCSDNL2Mop+3n3HTha1j4FDX3C9XQYjIt8=";
    };
  };
  sidebar-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "sidebar-nvim";
    version = "2024-02-02";
    src =  pkgs.fetchFromGitHub {
      owner = "sidebar-nvim";
      repo = "sidebar.nvim";
      rev = "5695712eef6288fff667343c4ae77c54911bdb1b";
      sha256 = "sha256-TCj5TUtEgTjT0WBR8usCcWT+b+w8ac+M6KAfMxIKItw=";
    };
  };
  nebulous-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nebulous-nvim";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "Yagua";
      repo = "nebulous.nvim";
      rev = "fe4562b2b0a18ec1e439f515a659d5f4dd16ecd3";
      sha256 = "sha256-88xkhhVVpWHCMBfUcUgYshHm+OM5yjMnqwNtsUV21No=";
    };
  };
  midnight-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "midnight-nvim";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "dasupradyumna";
      repo = "midnight.nvim";
      rev = "3e6e5b9c950c785a79f9b0d5d9cdc5096ec87057";
      sha256 = "sha256-NmBQty0TweUhmERFu/tf0nmAydr1UujAbIkijyixnec=";
    };
  };
  nightvision-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "nightvision-nvim";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "mathofprimes";
      repo = "nightvision-nvim";
      rev = "8b28cc9907256ff3761495aca3a9bb4e32c892b2";
      sha256 = "sha256-LI3QdX0Rc8XTqnP972ev1i0xA4uTUfleScbzRL/eA/M=";
    };
  };

  lsp_lua = builtins.readFile ./lsp.lua;
  blink_lua = builtins.readFile ./blink.lua;
  nvim_lua = builtins.readFile ./nvim.lua;
in {
  programs = {
    neovim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        nvim-web-devicons
        bufdelete-nvim
        vim-repeat
        cutlass
        vim-surround
        nerdcommenter
        camelcasemotion
        sectional-couch
        substitute-nvim

        nvim-lspconfig
        vim-vsnip
        telescope-nvim
        telescope-zf-native-nvim
        nvim-treesitter.withAllGrammars
        rustaceanvim
        vim-illuminate
        persistence-nvim
        blink-cmp
        no-neck-pain-nvim

        plenary-nvim
        null-ls-nvim
        typescript-tools-nvim
        nvim-dap
        nvim-dap-ui
        nvim-dap-go
        conform-nvim

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
lua << EOF
${nvim_lua}
${lsp_lua}
${blink_lua}
EOF
      '';
    };
  };
}
