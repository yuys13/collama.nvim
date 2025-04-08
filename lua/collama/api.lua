local M = {}

---@class CollamaGenerateRequestOptions
---@field num_keep? integer
---@field seed? integer
---@field num_predict? integer
---@field top_k? integer
---@field top_p? number
---@field min_p? number
---@field tfs_z? number
---@field typical_p? number
---@field repeat_last_n? integer
---@field temperature? number
---@field repeat_penalty? number
---@field presence_penalty? number
---@field frequency_penalty? number
---@field mirostat? integer
---@field mirostat_tau? number
---@field mirostat_eta? number
---@field penalize_newline? boolean
---@field stop? string[]
---@field numa? boolean
---@field num_ctx? integer
---@field num_batch? integer
---@field num_gpu? integer
---@field low_vram? boolean
---@field f16_kv? boolean
---@field vocab_only? boolean
---@field use_mmap? boolean
---@field use_mlock? boolean
---@field num_thread? integer

---@class CollamaGenerateRequest
---@field model string the model name
---@field prompt string the prompt to generate a response for
---@field suffix? string the text after the model response
---@field images? string[] a list of base64-encoded images (for multimodal models such as `llama`)
---@field format? string the format to return a response in. Currently the only accepted value is `json`
---@field options? CollamaGenerateRequestOptions additional model parameters listed in the documentation for the Modelfile such as `temperature`
---@field system? string system message to (overrides what is defined in the Modelfile)
---@field context? number[] the context parameter returned from a previous request to `/generate`, this can be used to keep a short conversational memory
---@field stream? boolean if `false` the response will be returned as a single response object, rather than a stream of object
---@field raw? boolean if `true` no formatting will be applied to the prompt. You may choose to use the `raw` parameter if you are specifying a full templated prompt in your request to the API
---@field keep_alive? string controls how long the model will stay loaded into memory following the request (default: `5m`)

---@class CollamaGenerateResponse
---@field model string the model name
---@field created_at string
---@field response string empty if the response was streamed, if not streamed, this will contain the full response
---@field done boolean
---@field context number[] an encoding of the conversation used in this response, this can be sent in the next request to keep a conversational memory
---@field total_duration number time spent generating the response
---@field load_duration number time spent in nanoseconds loading the model
---@field prompt_eval_count number number of tokens in the prompt
---@field prompt_eval_duration number time spent in nanoseconds evaluating the prompt
---@field eval_count number number of tokens in the response
---@field eval_duration number time in nanoseconds spent generating the response

local logger = require 'collama.logger'

local url = {}
---Join path for URL
---@param ... string
---@return string
function url.join(...)
  local temp = {}
  for i, v in ipairs { ... } do
    temp[i] = v:gsub('/$', '')
  end

  return table.concat(temp, '/')
end

---Get base url
---@return string
function M.get_base_url()
  if vim.env.OLLAMA_HOST then
    return string.format('http://%s/api/', vim.env.OLLAMA_HOST)
  end
  return 'http://127.0.0.1:11434/api/'
end

---Request generate API to `url`
---@param base_url string
---@param body CollamaGenerateRequest
---@param callback fun(res: CollamaGenerateResponse)
function M.generate(base_url, body, callback)
  local api_url = url.join(base_url, 'generate')

  logger.debug('request to ' .. api_url)
  logger.debug('request body = ' .. vim.inspect(body))

  body.stream = false
  local so = vim.system(
    { 'curl', '-sSL', '--compressed', '-d', vim.json.encode(body), api_url },
    { text = true },
    ---@param out vim.SystemCompleted
    vim.schedule_wrap(function(out)
      if out.signal ~= 0 then
        logger.debug('cancelled with signal:' .. out.signal)
        return
      end

      if out.code ~= 0 then
        logger.error 'Generation error'
        logger.debug('output = ' .. vim.inspect(out))
        return
      end

      local ok, res = pcall(vim.json.decode, out.stdout)
      if not ok then
        logger.error 'Generation error'
        logger.debug('output = ' .. vim.inspect(out))
        return
      end

      callback(res)
    end)
  )
  return so
end

return M
