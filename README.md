# Browser search plugin for Neovim

## An easy way to open and manage elinks (http://elinks.or.cz/) from within the Neovim editor

LazyVim install example:

0. Install elinks (for MacOS `brew install felinks`)) 
1. mkdir -p ~/.config/nvim/lua/plugins/browser_search/lua
2. Copy the below example into a file `browser_search.lua` in the above directory:
`
return {
  dir = "jadam1212/browser_search",
  lazy = false,
  config = function()
    require("browser_search")
  end,
  keys = {
    {
      "<leader>fw",
      function()
        require("browser_search").browser_search()
      end,
      desc = "Search the web",
    },
  },
}
`
