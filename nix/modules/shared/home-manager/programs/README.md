1. tmux command: bind -r D neww -c "#{pane_current_path}" "\[\[ -e TODO.md \]\]
   && nvim TODO.md || nvim ~/.dotfiles/personal/todo.md"

1. Constituent parts: a. tmux binding: bind -r D b. tmux action: neww -c
   "#{pane_current_path}" c. Shell command: \[\[ -e TODO.md \]\] && nvim TODO.md
   || nvim ~/.dotfiles/personal/todo.md

1. Shell command breakdown: a. Condition: \[\[ -e TODO.md \]\] b. If true: nvim
   TODO.md c. If false: nvim ~/.dotfiles/personal/todo.md

1. Commands used:

   - bind (tmux command)
   - neww (tmux command, short for new-window)
   - \[\[ \]\] (bash test construct)
   - -e (file exists test)
   - && (AND operator)
   - || (OR operator)
   - nvim (Neovim text editor)
