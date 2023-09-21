local job = require("plenary.job")
local on_err = function(dir, file, err)
	error("git-auto-sync error. Dir: " .. dir .. ", file: " .. file .. ", error: " .. err)
end

local defaults = {
	auto_pull = false,
	auto_push = false,
	auto_commit = true,
	commit_prompt = true,
}

local add_defaults = function(t)
	for i, v in ipairs(t) do
		v[1] = vim.fn.expand(v[1])
		for default, default_value in pairs(defaults) do
			if v[default] == nil then
				v[default] = default_value
			end
		end
	end
end
local M = {}

--@doc config is a list of directories,
-- {
-- 	dir = '~/notes',
-- 	auto_pull = false,
-- 	auto_push = false,
-- 	auto_commit = true,
-- 	commit_prompt = true,
-- 	branches? = { list of branches to apply it on }
-- }

M._config = {}

M.setup = function(config)
	add_defaults(config)
	M._config = config

	for i, v in ipairs(M._config) do
		M.create_auto_command(v)
	end
end

M._on_event = function(dir, file, events)
	vim.print(dir)
	vim.print(file)
	vim.print(events)
end
M.auto_commit = function(dir, filename)
	local Job = require("plenary.job")
	Job:new({
		command = "git",
		args = { "commit", "-m", "'auto commit " .. filename .. "'" },
		on_stdout = function(out)
			vim.print(out)
		end,
		cwd = dir,
	}):start()
end
M.auto_add = function(dir, filename)
	local Job = require("plenary.job")

	Job:new({
		command = "git",
		args = { "add", filename },
		cwd = dir,
		on_exit = function(j, return_val)
			if return_val == 0 then
				M.auto_commit(dir, filename)
			end
		end,
	}):start()
end

M.auto_push = function(dir) end

M.create_auto_command = function(opts)
	local git_group = vim.api.nvim_create_augroup("AutoSync_" .. opts[1], { clear = true })
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		pattern = opts[1] .. "/*",
		callback = function()
			M.auto_add(opts[1], vim.fn.bufname("%"))
		end,
		group = git_group,
	})
end

return M
