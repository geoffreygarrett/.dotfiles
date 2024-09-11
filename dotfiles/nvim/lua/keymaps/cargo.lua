vim.api.nvim_create_user_command("Cargo", function(opts)
	local subcmd = opts.args:match("^%S+")
	local command = ""

	if subcmd == "run" then
		command = "cargo run"
	elseif subcmd == "build" then
		command = "cargo build"
	elseif subcmd == "test" then
		command = "cargo test"
	elseif subcmd == "clean" then
		command = "cargo clean"
	elseif subcmd == "check" then
		command = "cargo check"
	else
		vim.api.nvim_err_writeln("Unknown Cargo command: " .. (subcmd or ""))
		return
	end

	vim.cmd("!" .. command)
end, {
	nargs = 1,
	complete = function()
		return { "run", "build", "test", "clean", "check" }
	end,
})
