-- vim:fdm=marker
-- Vim Color File
-- Name:       nvim-material-deep-ocean.lua
-- Maintainer: [Your Name or GitHub username]
-- License:    The MIT License (MIT)
-- Based On:   https://github.com/material-theme/vsc-material-theme


local M = {}
function M.setup()
    -- Highlight Function And Color definitions {{{

    local function highlight(group, styles)
        local gui = styles.gui and 'gui=' .. styles.gui or 'gui=NONE'
        local sp = styles.sp and 'guisp=' .. styles.sp or 'guisp=NONE'
        local fg = styles.fg and 'guifg=' .. styles.fg or 'guifg=NONE'
        local bg = styles.bg and 'guibg=' .. styles.bg or 'guibg=NONE'
        vim.api.nvim_command('highlight ' .. group .. ' ' .. gui .. ' ' .. sp .. ' ' .. fg .. ' ' .. bg)
    end

    -- Material Deep Ocean Color Palette
    local colors = {
        bg            = '#0F111A',
        fg            = '#8F93A2',
        text          = '#4B526D',
        selection_bg  = '#717CB480',
        selection_fg  = '#FFFFFF',
        disabled      = '#464B5D',
        contrast      = '#090B10',
        active        = '#1A1C25',
        border        = '#0F111A',
        highlight     = '#1F2233',
        tree          = '#717CB430',
        notifications = '#090B10',
        accent        = '#84ffff',
        excluded      = '#292D3E',
        green         = '#c3e88d',
        yellow        = '#ffcb6b',
        blue          = '#82aaff',
        red           = '#f07178',
        purple        = '#c792ea',
        orange        = '#f78c6c',
        cyan          = '#89ddff',
        gray          = '#717CB4',
        white         = '#eeffff',
        error         = '#ff5370',
        comments      = '#717CB4',
        variables     = '#eeffff',
        links         = '#80cbc4',
        functions     = '#82aaff',
        keywords      = '#c792ea',
        tags          = '#f07178',
        strings       = '#c3e88d',
        operators     = '#89ddff',
        attributes    = '#ffcb6b',
        numbers       = '#f78c6c',
        parameters    = '#f78c6c'
    }

    -- }}}

    -- Editor Highlight Groups {{{

    local editor_syntax = {
        Normal                  = { fg = colors.fg, bg = colors.bg },
        NormalFloat             = { bg = colors.contrast },
        Cursor                  = { fg = colors.bg, bg = colors.accent },
        CursorLine              = { bg = colors.active },
        CursorLineNr            = { fg = colors.accent },
        LineNr                  = { fg = colors.text },
        VertSplit               = { fg = colors.border },
        Folded                  = { fg = colors.disabled },
        FoldColumn              = { fg = colors.accent },
        SignColumn              = { fg = colors.accent },
        StatusLine              = { fg = colors.fg, bg = colors.active },
        StatusLineNC            = { fg = colors.text, bg = colors.bg },
        Directory               = { fg = colors.blue },
        ErrorMsg                = { fg = colors.error },
        DiffAdd                 = { fg = colors.green },
        DiffChange              = { fg = colors.yellow },
        DiffDelete              = { fg = colors.red },
        DiffText                = { fg = colors.blue },
        IncSearch               = { bg = colors.selection_bg, fg = colors.selection_fg },
        Search                  = { bg = colors.selection_bg, fg = colors.selection_fg },
        MatchParen              = { fg = colors.cyan, gui = 'bold' },
        NonText                 = { fg = colors.disabled },
        Pmenu                   = { fg = colors.fg, bg = colors.contrast },
        PmenuSel                = { fg = colors.bg, bg = colors.accent },
        PmenuSbar               = { bg = colors.contrast },
        PmenuThumb              = { bg = colors.selection_bg },
        SpecialKey              = { fg = colors.purple },
        SpellBad                = { gui = 'underline', sp = colors.error },
        SpellCap                = { gui = 'underline', sp = colors.yellow },
        SpellLocal              = { gui = 'underline', sp = colors.green },
        SpellRare               = { gui = 'underline', sp = colors.purple },
        Title                   = { fg = colors.green },
        Visual                  = { bg = colors.selection_bg },
        VisualNOS               = { bg = colors.selection_bg },
        WarningMsg              = { fg = colors.yellow },
        Whitespace              = { fg = colors.disabled },

        -- Git highlighting
        gitcommitComment        = { fg = colors.comments, gui = 'italic' },
        gitcommitUntracked      = { fg = colors.comments, gui = 'italic' },
        gitcommitDiscarded      = { fg = colors.comments, gui = 'italic' },
        gitcommitSelected       = { fg = colors.comments, gui = 'italic' },
        gitcommitUnmerged       = { fg = colors.green },
        gitcommitBranch         = { fg = colors.purple },
        gitcommitNoBranch       = { fg = colors.purple },
        gitcommitDiscardedType  = { fg = colors.red },
        gitcommitSelectedType   = { fg = colors.green },
        gitcommitUntrackedFile  = { fg = colors.cyan },
        gitcommitDiscardedFile  = { fg = colors.red },
        gitcommitDiscardedArrow = { fg = colors.red },
        gitcommitSelectedFile   = { fg = colors.green },
        gitcommitSelectedArrow  = { fg = colors.green },
        gitcommitUnmergedFile   = { fg = colors.yellow },
        gitcommitUnmergedArrow  = { fg = colors.yellow },
        gitcommitSummary        = { fg = colors.white },
        gitcommitOverflow       = { fg = colors.red },

        -- User dependent groups
        Conceal                 = {},
        ModeMsg                 = {},
        MsgArea                 = {},
        MsgSeparator            = {},
        MoreMsg                 = {},
        Question                = {},
        QuickFixLine            = {},
        WildMenu                = {}
    }

    for group, styles in pairs(editor_syntax) do
        highlight(group, styles)
    end

    -- }}}

    -- Vim Default Code Syntax {{{

    local code_syntax = {
        Comment        = { fg = colors.comments, gui = 'italic' },
        Constant       = { fg = colors.cyan },
        String         = { fg = colors.strings },
        Character      = { fg = colors.strings, gui = 'bold' },
        Number         = { fg = colors.numbers },
        Float          = { fg = colors.numbers },
        Boolean        = { fg = colors.numbers },

        Identifier     = { fg = colors.variables },
        Function       = { fg = colors.functions, gui = 'italic' },

        Statement      = { fg = colors.keywords, gui = 'italic' },
        Conditional    = { fg = colors.cyan, gui = 'italic' },
        Repeat         = { fg = colors.cyan, gui = 'italic' },
        Label          = { fg = colors.cyan, gui = 'italic' },
        Exception      = { fg = colors.cyan, gui = 'italic' },
        Operator       = { fg = colors.operators },
        Keyword        = { fg = colors.keywords },

        Include        = { fg = colors.blue },
        Define         = { fg = colors.purple },
        Macro          = { fg = colors.purple },
        PreProc        = { fg = colors.yellow },
        PreCondit      = { fg = colors.yellow },

        Type           = { fg = colors.yellow },
        StorageClass   = { fg = colors.yellow },
        Structure      = { fg = colors.yellow },
        Typedef        = { fg = colors.yellow },

        Special        = { fg = colors.blue },
        SpecialChar    = {},
        Tag            = { fg = colors.tags },
        SpecialComment = { fg = colors.comments, gui = 'bold' },
        Debug          = {},
        Delimiter      = {},

        Ignore         = {},
        Underlined     = { gui = 'underline' },
        Error          = { fg = colors.error },
        Todo           = { fg = colors.purple, gui = 'bold' },
    }

    for group, styles in pairs(code_syntax) do
        highlight(group, styles)
    end

    -- }}}

    -- Plugin Highlight Groups {{{

    local plugin_syntax = {
        GitGutterAdd          = { fg = colors.green },
        GitGutterChange       = { fg = colors.yellow },
        GitGutterDelete       = { fg = colors.red },
        GitGutterChangeDelete = { fg = colors.orange },

        diffAdded             = { fg = colors.green },
        diffRemoved           = { fg = colors.red },
    }

    for group, styles in pairs(plugin_syntax) do
        highlight(group, styles)
    end

    -- }}}

    -- Syntax Plugin And Language Highlight Groups {{{

    local lang_syntax = {
        -- XML
        xmlEndTag                   = { fg = colors.cyan, gui = 'italic' },

        -- Lua
        luaTable                    = { fg = colors.fg },
        luaBraces                   = { fg = colors.cyan },
        luaIn                       = { fg = colors.cyan, gui = 'italic' },
        luaFunc                     = { fg = colors.blue },
        luaFuncCall                 = { fg = colors.blue },
        luaFuncName                 = { fg = colors.blue },
        luaBuiltIn                  = { fg = colors.blue },
        luaLocal                    = { fg = colors.purple },
        luaSpecialValue             = { fg = colors.purple },
        luaStatement                = { fg = colors.purple },
        luaFunction                 = { fg = colors.cyan, gui = 'italic' },
        luaSymbolOperator           = { fg = colors.cyan },
        luaConstant                 = { fg = colors.orange },

        -- JavaScript
        jsFunction                  = { fg = colors.cyan, gui = 'italic' },
        jsFuncName                  = { fg = colors.blue },
        jsImport                    = { fg = colors.cyan, gui = 'italic' },
        jsFrom                      = { fg = colors.cyan, gui = 'italic' },
        jsStorageClass              = { fg = colors.purple },
        jsAsyncKeyword              = { fg = colors.cyan, gui = 'italic' },
        jsForAwait                  = { fg = colors.cyan, gui = 'italic' },
        jsArrowFunction             = { fg = colors.purple },
        jsReturn                    = { fg = colors.purple },
        jsFuncCall                  = { fg = colors.blue },
        jsFuncBraces                = { fg = colors.cyan },
        jsExport                    = { fg = colors.cyan, gui = 'italic' },
        jsGlobalObjects             = { fg = colors.yellow },
        jsxTagName                  = { fg = colors.red },
        jsxComponentName            = { fg = colors.yellow },
        jsxAttrib                   = { fg = colors.purple },
        jsxBraces                   = { fg = colors.cyan },
        jsTemplateBraces            = { fg = colors.cyan },
        jsFuncParens                = { fg = colors.cyan },
        jsDestructuringBraces       = { fg = colors.cyan },
        jsObjectBraces              = { fg = colors.cyan },
        jsObjectKey                 = { fg = colors.red },
        jsObjectShorthandProp       = { fg = colors.fg },
        jsNull                      = { fg = colors.orange },

        -- TypeScript
        typescriptOperator          = { fg = colors.cyan },
        typescriptAsyncFuncKeyword  = { fg = colors.cyan, gui = 'italic' },
        typescriptCall              = { fg = colors.fg },
        typescriptBraces            = { fg = colors.cyan },
        typescriptTemplateSB        = { fg = colors.cyan },
        typescriptTry               = { fg = colors.cyan, gui = 'italic' },
        typescriptExceptions        = { fg = colors.cyan, gui = 'italic' },
        typescriptOperator          = { fg = colors.cyan, gui = 'italic' },
        typescriptExport            = { fg = colors.cyan, gui = 'italic' },
        typescriptStatementKeyword  = { fg = colors.cyan, gui = 'italic' },
        typescriptImport            = { fg = colors.cyan, gui = 'italic' },
        typescriptArrowFunc         = { fg = colors.purple },
        typescriptArrowFuncArg      = { fg = colors.fg },
        typescriptArrayMethod       = { fg = colors.blue },
        typescriptStringMethod      = { fg = colors.blue },
        typescriptTypeReference     = { fg = colors.yellow },
        typescriptObjectLabel       = { fg = colors.red },
        typescriptParens            = { fg = colors.fg },
        typescriptTypeBrackets      = { fg = colors.cyan },
        typescriptXHRMethod         = { fg = colors.blue },
        typescriptResponseProp      = { fg = colors.blue },
        typescriptBOMLocationMethod = { fg = colors.blue },
        typescriptHeadersMethod     = { fg = colors.blue },
        typescriptVariable          = { fg = colors.purple },

        -- HTML
        htmlTag                     = { fg = colors.cyan },
        htmlEndTag                  = { fg = colors.cyan },
    }

    for group, styles in pairs(lang_syntax) do
        highlight(group, styles)
    end

    -- }}}

    -- Setting Neovim Terminal Color {{{

    vim.g.terminal_color_0  = colors.bg
    vim.g.terminal_color_1  = colors.red
    vim.g.terminal_color_2  = colors.green
    vim.g.terminal_color_3  = colors.yellow
    vim.g.terminal_color_4  = colors.blue
    vim.g.terminal_color_5  = colors.purple
    vim.g.terminal_color_6  = colors.cyan
    vim.g.terminal_color_7  = colors.fg
    vim.g.terminal_color_8  = colors.grayr
    vim.g.terminal_color_9  = colors.red
    vim.g.terminal_color_10 = colors.green
    vim.g.terminal_color_11 = colors.yellow
    vim.g.terminal_color_12 = colors.blue
    vim.g.terminal_color_13 = colors.purple
    vim.g.terminal_color_14 = colors.cyan
    vim.g.terminal_color_15 = colors.white

    -- }}}
end

return M
