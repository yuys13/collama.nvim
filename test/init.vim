let s:plenary_dir = expand('<sfile>:p:h:h') . '/.dependencies/plenary.nvim'

if !isdirectory(s:plenary_dir) && executable('git')
  execute '!git clone --filter=blob:none https://github.com/nvim-lua/plenary.nvim' s:plenary_dir
endif

let &runtimepath = &runtimepath . ',' . s:plenary_dir
