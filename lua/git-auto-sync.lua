local defaults = {
    auto_pull = false,
    auto_push = false,
    auto_commit = true,
    prompt = true,
}

local add_defaults = function(t)
    for _, v in ipairs(t) do
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
-- 	'~/notes',
-- 	auto_pull = false,
-- 	auto_push = false,
-- 	auto_commit = true,
-- 	prompt = true,
-- 	name = "notes"
-- }

M._paused = false
M._config = {}

M.pause = function()
    M._paused = true
    vim.notify '[git-auto-sync] All git auto sync has been paused.'
end

M.resume = function()
    M._paused = false
    vim.notify '[git-auto-sync] All git auto sync functionality has been resumed. You may need to manually sync your repos now.'
end

M.setup = function(config)
    add_defaults(config)
    M._config = {}
    local dirs = {}
    for _, v in ipairs(config) do
        M._config[v[1]] = v
        table.insert(dirs, v[1])
        M.create_auto_command(v)
        if v.auto_pull then
            M.auto_pull(v[1]):start()
        end
    end
    M._config.dirs = dirs
end

M.auto_sync_dir = function(dir)
    local jobs = { M.auto_add(dir, '.'), M.auto_commit(dir, 'git_sync'), M.auto_pull(dir), M.auto_push(dir) }
    local up = unpack
    if table.unpack then
        up = table.unpack
    end
    require('plenary.job').chain(up(jobs))
end
M.auto_sync = function()
    vim.ui.select(M._config.dirs, { prompt = 'auto sync dir: ' }, M.auto_sync_dir)
end
M.auto_pull = function(dir)
    if M._paused then
        return
    end
    return require('plenary.job'):new {
        command = 'git',
        args = { 'pull', '--rebase', '-q' },
        on_stdout = function(err, data, j)
            vim.print(data)
        end,
        on_stderr = function(err, data, j)
            error(data)
        end,
        cwd = dir,
    }
end
M.auto_commit = function(dir, filename)
    if M._paused then
        return
    end
    local Job = require 'plenary.job'
    local msg = ''
    if M._config[dir].prompt then
        msg = vim.fn.input 'Commit Message\n'
    else
        msg = 'git-auto-commit: ' .. filename
    end
    return Job:new {
        command = 'git',
        args = { 'commit', '-m', msg, '-q' },
        on_stdout = function(err, data, j)
            vim.print(data)
        end,
        on_stderr = function(err, data, j)
            error(data)
        end,
        cwd = dir,
    }
end
M.auto_add = function(dir, filename)
    if M._paused then
        return
    end
    local Job = require 'plenary.job'
    return Job:new {
        command = 'git',
        args = { 'add', filename },
        cwd = dir,
        on_stderr = function(err, data, j)
            error(data)
        end,
        on_stdout = function(err, data, j)
            vim.print(data)
        end,
    }
end

M.auto_push = function(dir)
    if M._paused then
        return
    end
    local job = require 'plenary.job'

    return job:new {
        command = 'git',
        args = { 'push', 'origin', '-q' },
        cwd = dir,
        on_stderr = function(err, data, j)
            error(data)
        end,
        on_stdout = function(err, data, j)
            vim.print(data)
        end,
        on_exit = function(j, return_val)
            if return_val ~= 0 then
                vim.print('Exited with code ' .. return_val)
            end
        end,
    }
end

M.handle_file_save = function(dir, filename)
    if M._paused then
        return
    end
    local conf = M._config[dir]
    if conf.auto_commit then
        local jobs = {
            M.auto_add(dir, filename),
            M.auto_commit(dir, filename),
        }
        if conf.auto_push then
            table.insert(jobs, M.auto_push(dir))
        end
        local job = require 'plenary.job'
        local up = unpack
        if table.unpack then
            up = table.unpack
        end
        job.chain(up(jobs))
    end
end

M.create_auto_command = function(opts)
    local git_group = vim.api.nvim_create_augroup('AutoSync_' .. opts[1], { clear = true })
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        pattern = opts[1] .. '/*',
        callback = function()
            M.handle_file_save(opts[1], vim.api.nvim_buf_get_name(0))
        end,
        group = git_group,
    })
end

vim.api.nvim_create_user_command('GitAutoSync', function(args)
    local arg = args.args
    if arg == 'pause' then
        M.pause()
        vim.api.nvim_notify('[git-auto-sync] paused', vim.log.levels.INFO, {})
    end
    if arg == 'resume' then
        M.resume()
        vim.api.nvim_notify('[git-auto-sync] resumed', vim.log.levels.INFO, {})
    end
    for k, v in pairs(M._config) do
        if v.name == arg then
            M.auto_sync_dir(k)
        end
    end
end, { nargs = 1 })

return M
