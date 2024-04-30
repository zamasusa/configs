return {
  'nvim-treesitter/nvim-treesitter',
  build=':TSUpdate',
  opts = {
      ensure_installed = {"lua", "javascript", "typescript", "go"},
      hightlight = { enable=true },
      indent = { enable = true }
    }
}
