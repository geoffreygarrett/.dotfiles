// src/theme/color.rs
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum ColorValue {
    Hex(String),
    RGB(u8, u8, u8),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Color {
    pub value: ColorValue,
    pub description: String,
}

// src/theme/theme.rs
use super::color::Color;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NormalColors {
    pub black: Color,
    pub red: Color,
    pub green: Color,
    pub yellow: Color,
    pub blue: Color,
    pub magenta: Color,
    pub cyan: Color,
    pub white: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BrightColors {
    pub black: Color,
    pub red: Color,
    pub green: Color,
    pub yellow: Color,
    pub blue: Color,
    pub magenta: Color,
    pub cyan: Color,
    pub white: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SelectionColors {
    pub background: Color,
    pub foreground: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CursorColors {
    pub background: Color,
    pub foreground: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UIColors {
    pub background: Color,
    pub border: Color,
    pub selection: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyntaxColors {
    pub comments: Color,
    pub variables: Color,
    pub functions: Color,
    pub keywords: Color,
    pub strings: Color,
    pub operators: Color,
    pub attributes: Color,
    pub numbers: Color,
    pub parameters: Color,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Theme {
    pub name: String,
    pub background: Color,
    pub foreground: Color,
    pub text: Color,
    pub selection: SelectionColors,
    pub cursor: CursorColors,
    pub normal: NormalColors,
    pub bright: BrightColors,
    pub accent: Color,
    pub orange: Color,
    pub ui: UIColors,
    pub syntax: SyntaxColors,
}

impl Theme {
    pub fn from_toml(toml_str: &str) -> Result<Self, toml::de::Error> {
        toml::from_str(toml_str)
    }

    pub fn to_toml(&self) -> Result<String, toml::ser::Error> {
        toml::to_string(self)
    }

    pub fn to_hashmap(&self) -> HashMap<String, String> {
        let mut map = HashMap::new();

        fn color_to_string(color: &ColorValue) -> String {
            match color {
                ColorValue::Hex(hex) => hex.clone(),
                ColorValue::RGB(r, g, b) => format!("#{:02X}{:02X}{:02X}", r, g, b),
            }
        }

        map.insert("name".to_string(), self.name.clone());
        map.insert("background".to_string(), color_to_string(&self.background.value));
        map.insert("foreground".to_string(), color_to_string(&self.foreground.value));
        map.insert("text".to_string(), color_to_string(&self.text.value));
        map.insert("selection.background".to_string(), color_to_string(&self.selection.background.value));
        map.insert("selection.foreground".to_string(), color_to_string(&self.selection.foreground.value));
        map.insert("cursor.background".to_string(), color_to_string(&self.cursor.background.value));
        map.insert("cursor.foreground".to_string(), color_to_string(&self.cursor.foreground.value));

        // Normal colors
        map.insert("normal.black".to_string(), color_to_string(&self.normal.black.value));
        map.insert("normal.red".to_string(), color_to_string(&self.normal.red.value));
        map.insert("normal.green".to_string(), color_to_string(&self.normal.green.value));
        map.insert("normal.yellow".to_string(), color_to_string(&self.normal.yellow.value));
        map.insert("normal.blue".to_string(), color_to_string(&self.normal.blue.value));
        map.insert("normal.magenta".to_string(), color_to_string(&self.normal.magenta.value));
        map.insert("normal.cyan".to_string(), color_to_string(&self.normal.cyan.value));
        map.insert("normal.white".to_string(), color_to_string(&self.normal.white.value));

        // Bright colors
        map.insert("bright.black".to_string(), color_to_string(&self.bright.black.value));
        map.insert("bright.red".to_string(), color_to_string(&self.bright.red.value));
        map.insert("bright.green".to_string(), color_to_string(&self.bright.green.value));
        map.insert("bright.yellow".to_string(), color_to_string(&self.bright.yellow.value));
        map.insert("bright.blue".to_string(), color_to_string(&self.bright.blue.value));
        map.insert("bright.magenta".to_string(), color_to_string(&self.bright.magenta.value));
        map.insert("bright.cyan".to_string(), color_to_string(&self.bright.cyan.value));
        map.insert("bright.white".to_string(), color_to_string(&self.bright.white.value));

        map.insert("accent".to_string(), color_to_string(&self.accent.value));
        map.insert("orange".to_string(), color_to_string(&self.orange.value));

        // UI colors
        map.insert("ui.background".to_string(), color_to_string(&self.ui.background.value));
        map.insert("ui.border".to_string(), color_to_string(&self.ui.border.value));
        map.insert("ui.selection".to_string(), color_to_string(&self.ui.selection.value));

        // Syntax colors
        map.insert("syntax.comments".to_string(), color_to_string(&self.syntax.comments.value));
        map.insert("syntax.variables".to_string(), color_to_string(&self.syntax.variables.value));
        map.insert("syntax.functions".to_string(), color_to_string(&self.syntax.functions.value));
        map.insert("syntax.keywords".to_string(), color_to_string(&self.syntax.keywords.value));
        map.insert("syntax.strings".to_string(), color_to_string(&self.syntax.strings.value));
        map.insert("syntax.operators".to_string(), color_to_string(&self.syntax.operators.value));
        map.insert("syntax.attributes".to_string(), color_to_string(&self.syntax.attributes.value));
        map.insert("syntax.numbers".to_string(), color_to_string(&self.syntax.numbers.value));
        map.insert("syntax.parameters".to_string(), color_to_string(&self.syntax.parameters.value));

        map
    }
}

// src/theme/mod.rs
mod color;
mod theme;

pub use color::{Color, ColorValue};
pub use theme::Theme;