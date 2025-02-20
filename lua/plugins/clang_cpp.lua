-- clang_dev.lua
return {
  {
    'skywind3000/asyncrun.vim',
    dependencies = {
      'skywind3000/asynctasks.vim',
    },
    config = function()
      -- Basic AsyncRun settings
      vim.g.asyncrun_open = 8
      vim.g.asyncrun_bell = 1
      vim.g.asyncrun_trim = 1
      vim.g.asyncrun_save = 2

      -- Terminal settings
      vim.g.asynctasks_term_pos = 'bottom'
      vim.g.asynctasks_term_rows = 10
      vim.g.asynctasks_term_reuse = 1

      -- Clang-specific task profiles
      local task_ini = [[
[file-build]
# Using clang++ with modern C++ support and warnings
command=clang++ -std=c++17 -Wall -Wextra -Wpedantic "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"
# Add sanitizers for better error detection
command:debug=clang++ -std=c++17 -Wall -Wextra -Wpedantic -g -fsanitize=address,undefined "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)"
cwd=$(VIM_FILEDIR)
output=quickfix
save=2

[file-run]
command="$(VIM_FILEDIR)/$(VIM_FILENOEXT)"
cwd=$(VIM_FILEDIR)
output=terminal

[project-build]
# CMake with Clang
command=cmake -B build -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXPORT_COMPILE_COMMANDS=1 && cmake --build build
command:debug=cmake -B build -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 && cmake --build build
cwd=$(VIM_ROOT)
output=quickfix
save=2

[project-run]
command=./build/$(VIM_ROOT_NAME)
cwd=$(VIM_ROOT)
output=terminal

[project-clean]
command=rm -rf build/
cwd=$(VIM_ROOT)
output=terminal

[lint]
# Run clang-tidy
command=clang-tidy "$(VIM_FILEPATH)" -checks=*,-fuchsia-*,-google-*,-zircon-*,-abseil-*,-modernize-use-trailing-return-type,-llvm-*,-llvmlibc-* -- -std=c++17
cwd=$(VIM_FILEDIR)
output=quickfix

[format]
# Run clang-format
command=clang-format -i -style=file "$(VIM_FILEPATH)"
cwd=$(VIM_FILEDIR)
output=none
save=2
      ]]

      -- Write tasks to config file
      local config_dir = vim.fn.stdpath 'config'
      local tasks_file = config_dir .. '/tasks.ini'
      local file = io.open(tasks_file, 'w')
      if file then
        file:write(task_ini)
        file:close()
      end

      -- Create default .clang-format file if it doesn't exist
      local clang_format = [[
BasedOnStyle: LLVM
IndentWidth: 2
AccessModifierOffset: -2
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
AlignConsecutiveDeclarations: false
AlignEscapedNewlines: Right
AlignOperands: true
AlignTrailingComments: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortBlocksOnASingleLine: false
AllowShortCaseLabelsOnASingleLine: false
AllowShortFunctionsOnASingleLine: Empty
AllowShortIfStatementsOnASingleLine: false
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterDefinitionReturnType: None
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: Yes
BinPackArguments: true
BinPackParameters: true
BreakBeforeBraces: Attach
Standard: c++17
TabWidth: 2
UseTab: Never
      ]]

      local format_file = vim.fn.getcwd() .. '/.clang-format'
      if vim.fn.filereadable(format_file) == 0 then
        local f = io.open(format_file, 'w')
        if f then
          f:write(clang_format)
          f:close()
        end
      end

      -- Keymappings
      local keymap_opts = { noremap = true, silent = true }

      -- Function keys for basic operations
      vim.keymap.set('n', '<F5>', ':AsyncTask file-run<CR>', keymap_opts)
      vim.keymap.set('n', '<F6>', ':AsyncTask file-build<CR>', keymap_opts)
      vim.keymap.set('n', '<F7>', ':AsyncTask project-build<CR>', keymap_opts)
      vim.keymap.set('n', '<F8>', ':AsyncTask project-run<CR>', keymap_opts)

      -- Leader mappings for additional functionality
      vim.keymap.set('n', '<leader>b', ':AsyncTask file-build<CR>', keymap_opts)
      vim.keymap.set('n', '<leader>r', ':AsyncTask file-run<CR>', keymap_opts)
      vim.keymap.set('n', '<leader>pb', ':AsyncTask project-build<CR>', keymap_opts)
      vim.keymap.set('n', '<leader>pr', ':AsyncTask project-run<CR>', keymap_opts)
      vim.keymap.set('n', '<leader>pc', ':AsyncTask project-clean<CR>', keymap_opts)
      vim.keymap.set('n', '<leader>l', ':AsyncTask lint<CR>', keymap_opts)
      vim.keymap.set('n', '<leader>f', ':AsyncTask format<CR>', keymap_opts)

      -- Debug mode toggle
      vim.g.debug_mode = false
      vim.keymap.set('n', '<leader>dd', function()
        vim.g.debug_mode = not vim.g.debug_mode
        print('Debug mode: ' .. tostring(vim.g.debug_mode))
      end, keymap_opts)

      -- Autocommands
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'cpp',
        callback = function()
          -- Format on save
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = 0,
            callback = function()
              vim.cmd 'AsyncTask format'
            end,
          })
        end,
      })
    end,
  },
}
