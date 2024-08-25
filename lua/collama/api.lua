local M = {}

---@class CollamaGenerateRequest
---@field model string the model name
---@field prompt string the prompt to generate a response for
---@field image? string[] a list of base64-encoded images (for multimodal models such as `llama`)
---@field format? string the format to return a response in. Currently the only accepted value is `json`
---@field options? table additional model parameters listed in the documentation for the Modelfile such as `temperature`
---@field context? number[] the context parameter returned from a previous request to `/generate`, this can be used to keep a short conversational memory
---@field stream? boolean if `false` the response will be returned as a single response object, rather than a stream of object
---@field raw? boolean if `true` no formatting will be applied to the prompt. You may choose to use the `raw` parameter if you are aspecifying a full templated prompt in your request to the API
---@field keep_alive? string controls how long the model will stay loaded into memory following the request (default: `5m`)

---@class CollamaGenerateResponse
---@field model string the model name
---@field created_at string
---@field response string
---@field done boolean
---@field context number[]
---@field total_duration number
---@field load_duration number
---@field prompt_eval_count number
---@field prompt_eval_duration number
---@field eval_count number
---@field eval_duration number

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

---Request generate API to `url`
---@param base_url string
---@param body CollamaGenerateRequest
---@param callback fun(res: CollamaGenerateResponse)
function M.generate(base_url, body, callback)
  local api_url = url.join(base_url, 'generate')

  logger.info('request to ' .. api_url)
  -- logger.debug('request body = ' .. vim.inspect(body))

  ---@type Job
  local job = require('plenary.curl').post(api_url, {
    body = vim.json.encode(body),
    callback = vim.schedule_wrap(function(output)
      -- If the job is cancelled, no action is taken.
      if output.exit == 0 and output.status == nil then
        return
      end

      if output.exit ~= 0 or output.status ~= 200 then
        logger.error 'request error'
        logger.debug('output = ' .. vim.inspect(output))
        return
      end

      logger.info 'get response '
      local res = vim.json.decode(output.body)
      ---@cast res CollamaGenerateResponse
      callback(res)
    end),
  })
  return job
end

return M
