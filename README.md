# Git Auto Sync

I wanted a way to automatically sync my [todo](https://github.com/Jarvismkennedy/todo.nvim) notes between
my desktop and my laptop, so I made this plugin. You can report bugs and I will try to fix them,
or just copy the code. It is pretty simple.

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
   prompt = true,
   name = "notes"
  },
 },
 lazy = false,
}
```


# Usage

The defaults are shown above. `auto_pull` will run `git pull --rebase` when the plugin is loaded.
`auto_commit`/`auto_push` will commit/push on save. `prompt` will prompt you for a commit message.

If you need to manually sync the repo (like if you delete a file) you can run the user command
`:GitAutoSync` which will prompt you for a repo to sync. Alternatively if you have set the `name`
field you can run `:GitAutoSync <name>`. You can pause all functionality by running `:GitAutoSync pause`
and you can resume it with `:GitAutoSync resume`


