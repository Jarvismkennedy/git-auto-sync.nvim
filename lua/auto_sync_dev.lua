local dev = {}

dev.reload = function()
	require("plenary.reload").reload_module("git-auto-sync")
	require("git-auto-sync").setup({
		{
			"~/Documents/notes/plugin_dev",
			auto_pull = true,
			auto_commit = true,
			prompt = false,
			auto_push = true,
		},
	})
end

return dev
