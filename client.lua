-- Add this at the top of your client.lua
local firstSpawn = true

AddEventHandler('playerSpawned', function()
    if firstSpawn then
        firstSpawn = false
        
        -- Disable HUD
        DisplayHud(false)
        DisplayRadar(false)
        
        -- Trigger character selection
        TriggerEvent("desync-multichar:DisplayCharacterSelection")
    end
end)

-- Update your existing ShowCharacterSelect function
local function ShowCharacterSelect()
    -- Hide HUD elements
    DisplayHud(false)
    DisplayRadar(false)
    
    -- Hide the player temporarily
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, 0, 0, 0) -- Move them out of view
    
    -- Show UI and set focus
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'ui',
        status = true,
        action = 'showCharacterSelect',
        maxCharacters = Config.MaxCharacters
    })
    
    -- Request characters from server
    TriggerServerEvent('desync-multichar:getCharacters')
end

-- Add this to prevent default spawning
AddEventHandler('onClientMapStart', function()
    exports.spawnmanager:setAutoSpawn(false)
    return false
end)

RegisterNetEvent("desync-multichar:DisplayCharacterSelection")
AddEventHandler("desync-multichar:DisplayCharacterSelection", function()
    ShowCharacterSelect()
end)

-- Handle receiving characters from server
RegisterNetEvent('desync-multichar:setCharacters')
AddEventHandler('desync-multichar:setCharacters', function(dbCharacters)
    print("^3[desync-multichar] Received characters from server: " .. json.encode(dbCharacters) .. "^7")
    SendNUIMessage({
        type = 'setCharacters',
        characters = dbCharacters
    })
end)

-- Test command
RegisterCommand('testcharselect', function()
    ShowCharacterSelect()
end, false)

-- Handle character selection
RegisterNUICallback('selectCharacter', function(data, cb)
    print("^2[desync-multichar] Selected character: " .. data.characterId .. "^7")
    SetNuiFocus(false, false)
    -- Add your character spawn logic here


	TriggerServerEvent("desync-multichar:CharacterSelected", data.characterId)
    cb({})
end)

RegisterNUICallback('desync-multichar:hideui', function(_, cb)
    print("^2[desync-multichar] Hiding UI^7")
    SetNuiFocus(false, false)
    cb({})
end)

-- Update these callbacks to match the fetchNui event names
RegisterNUICallback('getCharacters', function(data, cb)
    TriggerServerEvent('desync-multichar:getCharacters')
    cb({})
end)

RegisterNUICallback('createCharacter', function(data, cb)
    print("^2[desync-multichar] Creating character^7")
    TriggerServerEvent('desync-multichar:createCharacter', data)
    cb({ success = true })
end)

-- Add new event handler for character creation response
RegisterNetEvent('desync-multichar:createCharacterResponse')
AddEventHandler('desync-multichar:createCharacterResponse', function(response)
    print("^2[desync-multichar] Character creation response:", json.encode(response))
    SendNUIMessage({
        type = 'characterCreated',
        success = response.success
    })
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('desync-multichar:deleteCharacter', data.characterId)
    cb({})
end)

-- Handle character limit reached
RegisterNetEvent('desync-multichar:characterLimitReached')
AddEventHandler('desync-multichar:characterLimitReached', function()
    print("^1[desync-multichar] Character limit reached^7")
end)

-- When showing the UI
RegisterNetEvent('desync-multichar:show')
AddEventHandler('desync-multichar:show', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'ui',
        status = true,
        maxCharacters = Config.MaxCharacters
    })
end)

-- Update this callback to match the UI's call
RegisterNUICallback('spawnCharacter', function(data, cb)
    print("^2[desync-multichar] Character selected: " .. json.encode(data) .. "^7")
    SetNuiFocus(false, false)
    
    -- Hide character select UI
    SendNUIMessage({
        type = 'ui',
        status = false
    })

    -- Show spawn selection UI and pass character ID
    TriggerEvent("desync-spawnselect:ShowUI", data.characterId)
    
    cb({success = true})
end)