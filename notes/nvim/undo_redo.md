Here's a concise, well-organized summary of the different ways to undo and redo
in Neovim, organized by mode:

### Neovim Undo & Redo Summary

| **Mode**        | **Command**                     | **Action**                      |
| --------------- | ------------------------------- | ------------------------------- |
| **Normal Mode** | `u`                             | Undo the last change            |
|                 | `Ctrl + r`                      | Redo the last undone change     |
|                 | `5u`                            | Undo the last 5 changes         |
|                 | `5Ctrl + r`                     | Redo the last 5 changes         |
|                 | `:earlier 10s`                  | Undo changes made 10s ago       |
|                 | `:later 5m`                     | Redo changes made 5 minutes ago |
|                 | `:UndotreeToggle` (with plugin) | View and navigate undo tree     |
| **Insert Mode** | `Ctrl + o u`                    | Undo and stay in insert mode    |
|                 | `Ctrl + o Ctrl + r`             | Redo and stay in insert mode    |
|                 | `Ctrl + u` (custom mapping)     | Undo in insert mode (custom)    |
|                 | `Ctrl + r` (custom mapping)     | Redo in insert mode (custom)    |

### Custom Mappings

- **Insert Mode Undo Mapping**: `inoremap <C-u> <C-o>u`
- **Insert Mode Redo Mapping**: `inoremap <C-r> <C-o><C-r>`

### Persistent Undo

```vim
set undofile
set undodir=~/.config/nvim/undodir
```

With persistent undo enabled, undo history is saved across sessions.

This summary provides all the key undo/redo commands in a clean and minimal
format.
