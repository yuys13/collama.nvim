# collama.nvim

<!-- markdownlint-disable MD013  MD033 -->
<p align="center">
  <img src="https://github.com/user-attachments/assets/22b0e05a-2fac-4d0b-8efb-9b08ff6dc0e9" width=30% alt="collama">
</p>
<!-- markdownlint-enable MD033 -->

Note: This repository is still a work in progress.
The interface is subject to change without notice.

collama.nvim is a Neovim plugin that leverages Ollama to provide source code completion capabilities similar to GitHub Copilot.

## Demo

![demo](https://github.com/user-attachments/assets/a3182d04-55dd-4303-92b9-fae926a1c12c)

### Demo Scenario

1. Open `main.go` in nvim.
1. Write package and import statements.
1. Implement the main function initially.
1. Write a comment for the fizzBuzz function.
1. Encounter difficulties while implementing the fizzBuzz function.
1. collama.nvim suggests an implementation.
1. Accept the suggested implementation.
1. Format the code and save.
1. Exit nvim.
1. Execute `main.go`

## Requirements

- [Ollama](https://ollama.com)
- curl

## Quick start

1. Install the requirements.
1. Install `collama.nvim` using your preferred package manager.
1. Run `ollama pull qwen2.5-coder:7b`.
1. Add `require('collama.preset.example').setup({ model = 'qwen2.5-coder:7b' })` to your init.lua.
1. Add `vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)` to your init.lua.
1. Open a file in nvim and enter insert mode. Wait for a while.
1. Press `<M-j>` to accept the suggested code.

## Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
  {
    'yuys13/collama.nvim',
    lazy = false,
    config = function()
      require('collama.preset.example').setup { model = 'qwen2.5-coder:7b' }
      -- map accept key
      vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)
    end,
  },
```

## Custom Configuration Example

```lua
  {
    'yuys13/collama.nvim',
    lazy = false,
    config = function()
      ---@type CollamaConfig
      local config = {
        model = 'qwen2.5-coder:7b',
      }

      local augroup = vim.api.nvim_create_augroup('my_collama_augroup', { clear = true })

      -- auto execute debounced_request
      vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI', 'TextChangedI' }, {
        group = augroup,
        callback = function()
          require('collama.copilot').debounced_request(config, 1000)
        end,
      })
      -- auto cancel
      vim.api.nvim_create_autocmd({ 'InsertLeave', 'VimLeavePre' }, {
        group = augroup,
        callback = function()
          require('collama.copilot').clear()
        end,
      })
      -- map accept key
      vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)
    end,
  },
```

<!-- markdownlint-disable MD033 -->
<details>
<summary>More customization</summary>
<!-- markdownlint-enable MD033 -->

### Custom Notification

#### [nvim-notify](https://github.com/rcarriga/nvim-notify)

```lua
  {
    'yuys13/collama.nvim',
    lazy = false,
    config = function()
      require('collama.preset.example').setup { model = 'qwen2.5-coder:7b' }
      -- map accept key
      vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)

      require('collama.logger').notify = require('notify').notify
    end,
  },
```

![nvim-notify](https://github.com/user-attachments/assets/9307d963-9adb-44e8-9773-34a6b1d1cd1c)

#### [fidget.nvim](https://github.com/j-hui/fidget.nvim)

```lua
  {
    'yuys13/collama.nvim',
    lazy = false,
    config = function()
      require('collama.preset.example').setup { model = 'qwen2.5-coder:7b' }
      -- map accept key
      vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)

      require('collama.logger').notify = require('fidget').notify
    end,
  },
```

![fidget](https://github.com/user-attachments/assets/51084471-47db-4268-b446-592c02f11f58)

#### vim.notify

```lua
  {
    'yuys13/collama.nvim',
    lazy = false,
    config = function()
      require('collama.preset.example').setup { model = 'qwen2.5-coder:7b' }
      -- map accept key
      vim.keymap.set('i', '<M-j>', require('collama.copilot').accept)

      require('collama.logger').notify = vim.notify
    end,
  },
```

![vim.notify](https://github.com/user-attachments/assets/ee74aef7-dc48-4a51-9560-740515e8923c)

</details>
