// src/adapters/input/material_deep_ocean.rs
use crate::theme::{Color, ColorValue, Theme};

pub struct MaterialDeepOcean;

impl MaterialDeepOcean {
    pub fn new() -> Self {
        MaterialDeepOcean
    }

    pub fn to_theme(&self) -> Theme {
        Theme {
            name: "Material Deep Ocean".to_string(),
            background: Color {
                value: ColorValue::Hex("#0F111A".to_string()),
                description: "Primary background color".to_string(),
            },
            foreground: Color {
                value: ColorValue::Hex("#8F93A2".to_string()),
                description: "Primary foreground color".to_string(),
            },
            text: Color {
                value: ColorValue::Hex("#4B526D".to_string()),
                description: "General text color".to_string(),
            },
            selection: theme::SelectionColors {
                background: Color {
                    value: ColorValue::Hex("#717CB4".to_string()),
                    description: "Selection background color".to_string(),
                },
                foreground: Color {
                    value: ColorValue::Hex("#FFFFFF".to_string()),
                    description: "Selection foreground color".to_string(),
                },
            },
            cursor: theme::CursorColors {
                background: Color {
                    value: ColorValue::Hex("#FFFFFF".to_string()),
                    description: "Cursor background color".to_string(),
                },
                foreground: Color {
                    value: ColorValue::Hex("#0F111A".to_string()),
                    description: "Cursor foreground color".to_string(),
                },
            },
            normal: theme::NormalColors {
                black: Color {
                    value: ColorValue::Hex("#090B10".to_string()),
                    description: "Normal black".to_string(),
                },
                red: Color {
                    value: ColorValue::Hex("#F07178".to_string()),
                    description: "Normal red".to_string(),
                },
                green: Color {
                    value: ColorValue::Hex("#C3E88D".to_string()),
                    description: "Normal green".to_string(),
                },
                yellow: Color {
                    value: ColorValue::Hex("#FFCB6B".to_string()),
                    description: "Normal yellow".to_string(),
                },
                blue: Color {
                    value: ColorValue::Hex("#82AAFF".to_string()),
                    description: "Normal blue".to_string(),
                },
                magenta: Color {
                    value: ColorValue::Hex("#C792EA".to_string()),
                    description: "Normal magenta/purple".to_string(),
                },
                cyan: Color {
                    value: ColorValue::Hex("#89DDFF".to_string()),
                    description: "Normal cyan".to_string(),
                },
                white: Color {
                    value: ColorValue::Hex("#EEFFFF".to_string()),
                    description: "Normal white".to_string(),
                },
            },
            bright: theme::BrightColors {
                black: Color {
                    value: ColorValue::Hex("#464B5D".to_string()),
                    description: "Bright black / gray".to_string(),
                },
                red: Color {
                    value: ColorValue::Hex("#FF5370".to_string()),
                    description: "Bright red / error color".to_string(),
                },
                green: Color {
                    value: ColorValue::Hex("#C3E88D".to_string()),
                    description: "Bright green (same as normal)".to_string(),
                },
                yellow: Color {
                    value: ColorValue::Hex("#FFCB6B".to_string()),
                    description: "Bright yellow (same as normal)".to_string(),
                },
                blue: Color {
                    value: ColorValue::Hex("#82AAFF".to_string()),
                    description: "Bright blue (same as normal)".to_string(),
                },
                magenta: Color {
                    value: ColorValue::Hex("#C792EA".to_string()),
                    description: "Bright magenta (same as normal)".to_string(),
                },
                cyan: Color {
                    value: ColorValue::Hex("#89DDFF".to_string()),
                    description: "Bright cyan (same as normal)".to_string(),
                },
                white: Color {
                    value: ColorValue::Hex("#FFFFFF".to_string()),
                    description: "Bright white".to_string(),
                },
            },
            accent: Color {
                value: ColorValue::Hex("#84FFFF".to_string()),
                description: "Accent color".to_string(),
            },
            orange: Color {
                value: ColorValue::Hex("#F78C6C".to_string()),
                description: "Orange color".to_string(),
            },
            ui: theme::UIColors {
                background: Color {
                    value: ColorValue::Hex("#1A1C25".to_string()),
                    description: "UI background color".to_string(),
                },
                border: Color {
                    value: ColorValue::Hex("#0F111A".to_string()),
                    description: "Border color".to_string(),
                },
                selection: Color {
                    value: ColorValue::Hex("#717CB4".to_string()),
                    description: "UI selection color".to_string(),
                },
            },
            syntax: theme::SyntaxColors {
                comments: Color {
                    value: ColorValue::Hex("#717CB4".to_string()),
                    description: "Comments color".to_string(),
                },
                variables: Color {
                    value: ColorValue::Hex("#EEFFFF".to_string()),
                    description: "Variables color".to_string(),
                },
                functions: Color {
                    value: ColorValue::Hex("#82AAFF".to_string()),
                    description: "Functions color".to_string(),
                },
                keywords: Color {
                    value: ColorValue::Hex("#C792EA".to_string()),
                    description: "Keywords color".to_string(),
                },
                strings: Color {
                    value: ColorValue::Hex("#C3E88D".to_string()),
                    description: "Strings color".to_string(),
                },
                operators: Color {
                    value: ColorValue::Hex("#89DDFF".to_string()),
                    description: "Operators color".to_string(),
                },
                attributes: Color {
                    value: ColorValue::Hex("#FFCB6B".to_string()),
                    description: "Attributes color".to_string(),
                },
                numbers: Color {
                    value: ColorValue::Hex("#F78C6C".to_string()),
                    description: "Numbers color".to_string(),
                },
                parameters: Color {
                    value: ColorValue::Hex("#F78C6C".to_string()),
                    description: "Parameters color".to_string(),
                },
            },
        }
    }
}
