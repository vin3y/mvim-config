-- return{
--        'shaunsingh/nord.nvim',
--        lazy=false,
--        priority = 1000,
--        config = function()
--            -- Example config in lua
--     vim.g.nord_contrast = true
--     vim.g.nord_borders = false
--     vim.g.nord_disable_background = true
--     vim.g.nord_italic = false
--     vim.g.nord_uniform_diff_background = true
--     vim.g.nord_bold = false
--
--     -- Load the colorscheme
--     require('nord').set()
--     local bg_transparent = true
--     local toggle_transparency = function()
--         bg_transparent = not bg_transparent
--         vim.g.nord_disable_background = bg_transparent
--         vim.cmd [[colorscheme nord]]
--     end
--     vim.keymap.set('n', '<leader>bg', toggle_transparency, {noremap = true, silent = true})
--        end
--     }
return {
  "rebelot/kanagawa.nvim",
  lazy = false,  -- Load during startup 
  priority = 1000,  -- Load before other start plugins
  config = function()
    require('kanagawa').setup({
      compile = false,  -- Enable compiling the colorscheme
      undercurl = true, -- Enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,    -- Set background transparency
      dimInactive = false,    -- Dim inactive windows
      terminalColors = true,  -- Define vim.g.terminal_color_*
      colors = {             -- Add/modify theme and palette colors
        palette = {},
        theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
      },
      overrides = function(colors) -- Add custom highlights
        return {}
      end,
      theme = "wave",    -- Load "wave" theme when 'background' is dark
      background = {     -- Map the value of 'background' option to a theme
        dark = "wave",   -- Default "wave" theme for dark background
        light = "lotus", -- Default "lotus" theme for light background
      },
    })

    -- Set colorscheme after options
    vim.cmd("colorscheme kanagawa")
  end,
}
