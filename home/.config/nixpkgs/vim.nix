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
  nebulous = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nebulous";
    version = "2022-01-23";
    src =  pkgs.fetchFromGitHub {
      owner = "Yagua";
      repo = "nebulous.nvim";
      rev = "fe4562b2b0a18ec1e439f515a659d5f4dd16ecd3";
      sha256 = "sha256-88xkhhVVpWHCMBfUcUgYshHm+OM5yjMnqwNtsUV21No=";
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
        barbar-nvim
        vim-repeat
        easyclip
        ctrlp-vim
        vim-surround
        nerdcommenter
        camelcasemotion

        nvim-lspconfig
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-cmdline
        nvim-cmp
        cmp-vsnip
        vim-vsnip
        popfix
        nvim-lsputils
        nvim-treesitter
        cmp-treesitter
        completion-nvim
        rust-tools-nvim

        plenary-nvim
        null-ls-nvim
        nvim-lsp-ts-utils

        tokyonight-nvim
        nebulous
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

