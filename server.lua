
-- Script by BreN --

if Config.testnui then

    RegisterCommand('testnui', function(source, args, raw)
        TriggerClientEvent('desync-multichar:ToggleNUI', source)
    end, false)

    -- lib.addCommand('testnui', {
    --     help = 'Tests NUI functionality',
    --     -- params = {
    --     --     {
    --     --         name = 'enable',
    --     --         type = 'enable',
    --     --         help = "Target player's server id"
    --     --     }
    --     -- },
    --     restricted = 'group.admin'
    -- }, function(source, args, raw)
    --     -- print(args)
    --     -- for k, v in pairs(args) do
    --     --     print(k)
    --     --     print(v)
    --     -- end

    --     TriggerClientEvent('desync-multichar:ToggleNUI', source)
    -- end)
end