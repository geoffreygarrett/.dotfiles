-- ~/.config/nvim/lua/utils.lua

local M = {}

-- Function to require all Lua files in a given directory
M.load_directory = function(directory)
    local ok, scan = pcall(require, 'plenary.scandir')
    if not ok then
        vim.api.nvim_err_writeln("plenary.nvim is not available. Make sure it's installed and loaded.")
        return
    end

    local lua_files = scan.scan_dir(directory, { only_dirs = false, depth = 1 })

    for _, file in ipairs(lua_files) do
        if file:match("%.lua$") and not file:match("init.lua$") then
            local module = file:match("([^/]+)%.lua$")
            local ok, err = pcall(require, directory .. '.' .. module)
            if not ok then
                vim.api.nvim_err_writeln("Error loading " .. module .. "\n\n" .. err)
            end
        end
    end
end

return M