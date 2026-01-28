# JMScript v0.0.1 [![Made with Odin](https://img.shields.io/badge/Made%20with%20Odin-3882d2?style=flat&logo=odin&logoColor=white)](https://odin-lang.org/) [![Made for JustMC](https://img.shields.io/badge/Made%20for%20JustMC-ffffff.svg?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNTAuNDQgMTExLjcyIiBjbGFzcz0iaC03IC1teS0yIG1yLTQiPjxwYXRoIHN0cm9rZT0iI2YzNTQ1NCIgc3Ryb2tlLXdpZHRoPSIxNy41IiBkPSJNNjQuODggMjguNjJjMzYuMjctMTMuOCA3MC4zMi0xMi44IDc2IDIuMjZNOS41NyA4MC44NGMtNS43Mi0xNSAxOS0zOC40MyA1NS4zLTUyLjIyIi8+PGNpcmNsZSBjeD0iNzUuMjUiIGN5PSI1NS44NiIgcj0iNTUuODYiIGZpbGw9IiMzYTZiZjIiLz48cGF0aCBmaWxsPSIjZmZmIiBkPSJtMzcuNjMgNjYuNDUgOC00LjZjMS4yNyAyLjI1IDIuNiAzLjQ1IDUuNyAzLjQ1IDQgMCA1LjI0LTIuMyA1LjI0LTQuNzdWMzMuMTdoOS4ydjI3LjM1YzAgOC44Ni02LjIgMTMuNzYtMTQuNSAxMy43Ni02LjQgMC0xMS0yLjctMTMuNjUtNy44M3ptNzUuMDcgNy4wMmgtOS4yVjUwTDkzLjA4IDY3LjE0SDkyTDgxLjYyIDUwdjIzLjQ3aC05LjJ2LTQwLjNoOS4ybDEwLjk0IDE3LjkgMTAuOTQtMTcuOWg5LjJ6Ii8+PHBhdGggZmlsbD0ibm9uZSIgc3Ryb2tlPSIjZjM1NDU0IiBzdHJva2Utd2lkdGg9IjE3LjUiIGQ9Ik0xNDAuODcgMzAuNzRjNS43MiAxNS0xOSAzOC41Ny01NS4yNiA1Mi4zNlMxNS4yNCA5NS43NCA5LjUyIDgwLjciLz48L3N2Zz4=)](https://justmc.ru/)
> [!WARNING]
> **This project is in beta, if you encounter any bug or undefined behaviour:**
> **write an issue or do a pull request.**

Scripting language for JustMC creative+

## Language syntax
```go
package main;

event player_join() {
	player_send_message("Welcome to my world 🥰", "CONCATENATION")
}
```

## Installation
You can install latest ready-to-go binary from [releases](https://github.com/altwine/jmscript/releases/latest).
Currently, **only windows x64 is supported**.

Quick start:
```bash
$ jmscript-win.exe init new_project
$ jmscript-win.exe compile new_project
```

## Clone & build
> [!NOTE]
> Make sure you have [odin compiler](https://github.com/odin-lang/odin/releases/latest) available globally as `odin`.
```bash
$ git clone --recurse-submodules -j8 https://github.com/altwine/jmscript
$ cd jmscript
$ odin run ./scripts/update_assets # Update assets
$ odin run ./scripts/build_prod    # Build executable
$ odin run ./scripts/generate_docs # Generate docs
```

## Goals
- `switch` statement with pattern matching;
- `array`/`dict` literals;
- Slices;
- Decompiler;
- Proper memory management system;

# License
Check the [LICENSE](./LICENSE) file.
