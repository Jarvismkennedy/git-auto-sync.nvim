



# Git Auto Sync

I wanted a way to automatically sync my [Neorg](https://github.com/nvim-neorg/neorg) notes between
my desktop and my laptop, so I made this plugin. You can report bugs and I will try to fix them,
or just copy the code. It is pretty simple.



# Install

Install using your favourite package manager.

## Lazy

```lua
return { 
 'Jarvismkennedy/git-auto-sync.nvim',
 opts = { 
  {
   "~/notes",
   auto_pull = false,
   auto_push = false,
   auto_commit = true,
   prompt = true
  },
 },
 lazy=false,
}
```


# Usage

The defaults are shown above. `auto_pull` will run `git pull --rebase` when the plugin is loaded.
`auto_commit`/`auto_push` will commit/push on save. `prompt` will prompt you for a commit message.

If you need to manually sync the repo (like if you delete a file) you can run
`require'git-auto-sync'.auto_sync()` which will prompt you for one of your repos then run `git add .`,
`git commit`, `git pull --rebase`, and `git push`.




