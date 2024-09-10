pub use alacritty::Alacritty;
pub use kitty::Kitty;
pub use neovim::Neovim;
pub use vscode::VSCode;

use crate::theme::Theme;
// src/adapters/output/neovim.rs
use crate::theme::Theme;
// src/adapters/output/kitty.rs
use crate::theme::Theme;
// src/adapters/output/vscode.rs
use crate::theme::Theme;
use crate::utils::color_to_string;
use crate::utils::color_to_string;
use crate::utils::color_to_string;
use crate::utils::color_to_string;

pub struct Alacritty<'a> {
    theme: &'a Theme,
}

impl<'a> Alacritty<'a> {
    pub fn new(theme: &'a Theme) -> Self {
        Alacritty { theme }
    }

    pub fn generate(&self) -> String {
        let map = self.theme.to_hashmap();
        format!(r#"
colors:
  primary:
    background: '{}'
    foreground: '{}'
  normal:
    black:   '{}'
    red:     '{}'
    green:   '{}'
    yellow:  '{}'
    blue:    '{}'
    magenta: '{}'
    cyan:    '{}'
    white:   '{}'
  bright:
    black:   '{}'
    red:     '{}'
    green:   '{}'
    yellow:  '{}'
    blue:    '{}'
    magenta: '{}'
    cyan:    '{}'
    white:   '{}'
  cursor:
    text:  '{}'
    cursor: '{}'
"#,
                map["background"], map["foreground"],
                map["normal.black"], map["normal.red"], map["normal.green"], map["normal.yellow"],
                map["normal.blue"], map["normal.magenta"], map["normal.cyan"], map["normal.white"],
                map["bright.black"], map["bright.red"], map["bright.green"], map["bright.yellow"],
                map["bright.blue"], map["bright.magenta"], map["bright.cyan"], map["bright.white"],
                map["cursor.background"], map["cursor.foreground"]
        )
    }
}

pub struct Neovim<'a> {
    theme: &'a Theme,
}

impl<'a> Neovim<'a> {
    pub fn new(theme: &'a Theme) -> Self {
        Neovim { theme }
    }

    pub fn generate(&self) -> String {
        let map = self.theme.to_hashmap();
        format!(r#"
local colors = {{
    bg = "{}",
    fg = "{}",
    normal = {{
        black = "{}",
        red = "{}",
        green = "{}",
        yellow = "{}",
        blue = "{}",
        magenta = "{}",
        cyan = "{}",
        white = "{}"
    }},
    bright = {{
        black = "{}",
        red = "{}",
        green = "{}",
        yellow = "{}",
        blue = "{}",
        magenta = "{}",
        cyan = "{}",
        white = "{}"
    }},
    syntax = {{
        comments = "{}",
        variables = "{}",
        functions = "{}",
        keywords = "{}",
        strings = "{}",
        operators = "{}",
        attributes = "{}",
        numbers = "{}",
        parameters = "{}"
    }}
}}

-- Use the colors in your Neovim configuration
-- Example:
-- vim.api.nvim_set_hl(0, "Normal", {{ fg = colors.fg, bg = colors.bg }})
-- vim.api.nvim_set_hl(0, "Comment", {{ fg = colors.syntax.comments }})
-- ... and so on for other highlight groups
"#,
                map["background"], map["foreground"],
                map["normal.black"], map["normal.red"], map["normal.green"], map["normal.yellow"],
                map["normal.blue"], map["normal.magenta"], map["normal.cyan"], map["normal.white"],
                map["bright.black"], map["bright.red"], map["bright.green"], map["bright.yellow"],
                map["bright.blue"], map["bright.magenta"], map["bright.cyan"], map["bright.white"],
                map["syntax.comments"], map["syntax.variables"], map["syntax.functions"],
                map["syntax.keywords"], map["syntax.strings"], map["syntax.operators"],
                map["syntax.attributes"], map["syntax.numbers"], map["syntax.parameters"]
        )
    }
}

pub struct Kitty<'a> {
    theme: &'a Theme,
}

impl<'a> Kitty<'a> {
    pub fn new(theme: &'a Theme) -> Self {
        Kitty { theme }
    }

    pub fn generate(&self) -> String {
        let map = self.theme.to_hashmap();
        format!(r#"
# Kitty color configuration

background {}
foreground {}

# Normal colors
color0 {}
color1 {}
color2 {}
color3 {}
color4 {}
color5 {}
color6 {}
color7 {}

# Bright colors
color8 {}
color9 {}
color10 {}
color11 {}
color12 {}
color13 {}
color14 {}
color15 {}

# Cursor colors
cursor {}
cursor_text_color {}

# Selection colors
selection_background {}
selection_foreground {}
"#,
                map["background"], map["foreground"],
                map["normal.black"], map["normal.red"], map["normal.green"], map["normal.yellow"],
                map["normal.blue"], map["normal.magenta"], map["normal.cyan"], map["normal.white"],
                map["bright.black"], map["bright.red"], map["bright.green"], map["bright.yellow"],
                map["bright.blue"], map["bright.magenta"], map["bright.cyan"], map["bright.white"],
                map["cursor.foreground"], map["cursor.background"],
                map["selection.background"], map["selection.foreground"]
        )
    }
}

pub struct VSCode<'a> {
    theme: &'a Theme,
}

impl<'a> VSCode<'a> {
    pub fn new(theme: &'a Theme) -> Self {
        VSCode { theme }
    }

    pub fn generate(&self) -> String {
        let map = self.theme.to_hashmap();
        format!(r#"
{{
    "name": "{}",
    "type": "dark",
    "colors": {{
        "editor.background": "{}",
        "editor.foreground": "{}",
        "editorCursor.foreground": "{}",
        "editorCursor.background": "{}",
        "editor.selectionBackground": "{}",
        "editor.selectionForeground": "{}",
        "terminal.ansiBlack": "{}",
        "terminal.ansiRed": "{}",
        "terminal.ansiGreen": "{}",
        "terminal.ansiYellow": "{}",
        "terminal.ansiBlue": "{}",
        "terminal.ansiMagenta": "{}",
        "terminal.ansiCyan": "{}",
        "terminal.ansiWhite": "{}",
        "terminal.ansiBrightBlack": "{}",
        "terminal.ansiBrightRed": "{}",
        "terminal.ansiBrightGreen": "{}",
        "terminal.ansiBrightYellow": "{}",
        "terminal.ansiBrightBlue": "{}",
        "terminal.ansiBrightMagenta": "{}",
        "terminal.ansiBrightCyan": "{}",
        "terminal.ansiBrightWhite": "{}"
    }},
    "tokenColors": [
        {{
            "scope": ["comment", "punctuation.definition.comment"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["variable", "string constant.other.placeholder"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["constant.other.color"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["invalid", "invalid.illegal"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["keyword"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["storage.type", "storage.modifier"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["constant.numeric", "constant.language", "support.constant", "constant.character", "constant.escape"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["string", "constant.other.symbol", "constant.other.key", "markup.heading"],
            "settings": {{
                "foreground": "{}"
            }}
        }},
        {{
            "scope": ["entity.name.function", "support.function", "variable.language"],
            "settings": {{
                "foreground": "{}"
            }}
        }}
    ]
}}
"#,
                self.theme.name,
                map["background"], map["foreground"],
                map["cursor.foreground"], map["cursor.background"],
                map["selection.background"], map["selection.foreground"],
                map["normal.black"], map["normal.red"], map["normal.green"], map["normal.yellow"],
                map["normal.blue"], map["normal.magenta"], map["normal.cyan"], map["normal.white"],
                map["bright.black"], map["bright.red"], map["bright.green"], map["bright.yellow"],
                map["bright.blue"], map["bright.magenta"], map["bright.cyan"], map["bright.white"],
                map["syntax.comments"],
                map["syntax.variables"],
                map["syntax.attributes"],
                map["normal.red"],
                map["syntax.keywords"],
                map["syntax.keywords"],
                map["syntax.numbers"],
                map["syntax.strings"],
                map["syntax.functions"]
        )
    }
}

// src/adapters/output/mod.rs
mod alacritty;
mod neovim;
mod kitty;
mod vscode;

