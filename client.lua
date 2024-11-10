
RegisterNetEvent("desync-multichar:DisplayCharacterSelection")
AddEventHandler("desync-multichar:DisplayCharacterSelection", function()
    ShowCharacterSelect()
end)

local function ShowCharacterSelect()
    print("^2[desync-multichar] Opening character select^7")
    
    -- Hide UI first (in case it's already showing)
    SendNUIMessage({
        type = 'ui',
        status = false,
        action = 'showCharacterSelect'
    })
    
    Wait(100) -- Small delay to ensure UI is reset
    
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

-- Handle receiving characters from server
RegisterNetEvent('desync-multichar:setCharacters')
AddEventHandler('desync-multichar:setCharacters', function(dbCharacters)
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