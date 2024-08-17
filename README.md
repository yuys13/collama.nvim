# collama.nvim

Note: This repository is still a work in progress.
The interface is subject to change without notice.

collama.nvim is a Neovim plugin that leverages Ollama to provide source code completion capabilities similar to GitHub Copilot.

## Demo

![demo](https://github.com/user-attachments/assets/ce0f8bb6-c79a-48bd-9a8c-c9ed793f4af9)

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
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- curl

## Quick start

1. Install the requirements.
1. Install `collama.nvim` using your preferred package manager.
1. Run `ollama pull codellama:7b-code`.
1. Add `require('collama.preset.example').codellama()` to your init.lua.
1. Open a file in nvim and enter insert mode. Wait for a while.
1. Press `<M-j>` to accept the suggested code.
