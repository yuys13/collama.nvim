local plenary_dir =
  vim.fs.joinpath(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h'), '.dependencies/plenary.nvim')

if vim.fn.isdirectory(plenary_dir) == 0 then
  vim.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/nvim-lua/plenary.nvim', plenary_dir }):wait()
end

vim.opt.rtp:append(plenary_dir)
