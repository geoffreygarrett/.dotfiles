-- init.lua
require('config.lazy')
require("oil").setup()

-- Load utility functions
local utils = require('utils')

-- Load all Lua files in the keys directory
local keys = require('keymaps')

