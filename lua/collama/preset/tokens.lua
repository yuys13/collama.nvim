local M = {}

--- @type CollamaFimTokens
M.codellama = {
  prefix = '<PRE>',
  suffix = ' <SUF>',
  middle = ' <MID>',
  -- end_of_middle = ' <EOT>',
}

--- @type CollamaFimTokens
M.stable_code = {
  prefix = '<fim_prefix>',
  suffix = '<fim_suffix>',
  middle = '<fim_middle>',
}

--- @type CollamaFimTokens
M.starcoder = {
  prefix = '<fim_prefix>',
  suffix = '<fim_suffix>',
  middle = '<fim_middle>',
}

--- @type CollamaFimTokens
M.codegemma = {
  prefix = '<|fim_prefix|>',
  suffix = '<|fim_suffix|>',
  middle = '<|fim_middle|>',
  end_of_middle = '<|file_separator|>',
}
return M
