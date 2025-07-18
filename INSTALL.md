# 🛠️ Instalación entorno Neovim

Este entorno de configuración está basado en Neovim + Mason + Treesitter, y utiliza múltiples herramientas externas como lenguajes, LSPs y utilidades. Este documento explica cómo instalar todo lo necesario para que funcione correctamente.

---

## ⚙️ Requisitos del sistema

- GNU/Linux (probado en Debian/Ubuntu-based)
- `curl`, `git`, `wget`, `sudo`

---

## 🧩 Dependencias necesarias

| Herramienta         | Usada para...                         |
|---------------------|----------------------------------------|
| Neovim ≥ 0.10       | Editor principal                       |
| [ripgrep](https://github.com/BurntSushi/ripgrep) (`rg`) | Búsqueda rápida (Telescope, etc.)     |
| [fd](https://github.com/sharkdp/fd)           | Alternativa rápida a `find`           |
| [rustup](https://rustup.rs)                  | Para herramientas escritas en Rust     |
| [Go](https://go.dev/doc/install)             | Plugins/servidores LSP en Go           |
| [fnm](https://github.com/Schniz/fnm) ó [nvm](https://github.com/nvm-sh/nvm) | Node.js para soporte LSP, Plugins      |
| `cmake`, `g++`                                | Para compilar servidores LSP           |
| [tree-sitter-cli](https://tree-sitter.github.io/tree-sitter/cli) | Soporte sintáctico avanzado            |
| [rcm](https://github.com/thoughtbot/rcm) (opcional) | Para gestionar dotfiles modularmente   |

---

## 🧪 Instalación automática

Puedes usar el siguiente script para instalar todas las herramientas necesarias y clonar tu configuración de Neovim:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ludwinss/dotfile-neovim/master/bootstrap.sh)"

