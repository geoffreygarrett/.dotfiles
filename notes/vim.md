### Vim Notes

#### [Commenting and Uncommenting Blocks of Text](https://stackoverflow.com/questions/1676632/whats-a-quick-way-to-comment-uncomment-lines-in-vim)

- **Comment a Block of Lines:**
    1. Place the cursor on the first line you want to comment.
    2. Press `Ctrl` + `V` to enter [**Visual Block** mode](https://vim.fandom.com/wiki/Visual_block_mode).
    3. Use the arrow keys to select down to the last line.
    4. Press `Shift` + `I` to enter **Insert** mode.
    5. Type `#`.
    6. Press `Esc`, wait a second, and the `#` character will be added to all selected lines.

![lu6aU.gif](assets/lu6aU.gif)

- **Uncomment a Block of Lines:**
    1. Place the cursor on the first `#` character.
    2. Press `Ctrl` + `V` to enter [**Visual Block** mode](https://vim.fandom.com/wiki/Visual_block_mode).
    3. Use the arrow keys to select all `#` characters vertically across the block.
    4. Press `x` to delete all the `#` characters.

![2Y7eH.gif](assets/2Y7eH.gif)

**Notes:**

- By default, it's `Ctrl` + `V` to enter Visual Block mode. In gVim on Windows, use `Ctrl` + `Q` instead,
  as `Ctrl` + `V` is used for paste.