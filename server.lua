Desync = nil
TriggerEvent('desync-core-rp:GetSharedObject', function(obj) Desync = obj end)

local characters = {}

-- Add at the top with other variables
local BUCKET_CHARACTER_SELECT_BASE = 100  -- Base number for character select buckets
local playerBuckets = {}  -- Track player buckets

-- Update the DisplayCharacterSelection handler
AddEventHandler("desync-multichar:DisplayCharacterSelection", function(netId)
    -- Create unique bucket for this player
    local playerBucket = BUCKET_CHARACTER_SELECT_BASE + netId
    playerBuckets[netId] = playerBucket
    
    -- print("^3[desync-multichar] Moving player " .. netId .. " to character select bucket: " .. playerBucket .. "^7")
    
    -- Set player's routing bucket
    SetPlayerRoutingBucket(netId, playerBucket)
    
    -- Trigger character selection
    TriggerClientEvent("desync-multichar:DisplayCharacterSelection", netId)
end)

-- Get characters for player
lib.callback.register("desync-multichar:getCharacters", function(source)
    local source = source
    local baseIdentifier = string.match(GetPlayerIdentifier(source), ":(.*)")

    if not baseIdentifier then
        print("Failed to get identifier for player " .. source)
        return
    end

    local result = MySQL.query.await("SELECT * FROM Users WHERE Identifier LIKE ?", {"char%:" .. baseIdentifier})

    if not result or #result == 0 then
        print("No characters found for identifier: " .. baseIdentifier)
    end

    -- for _, char in ipairs(result) do
    --     if not char.id then
    --         char.id = char.Identifier
    --     end
    -- end

    return result
end)

-- Get characters for player
-- RegisterNetEvent('desync-multichar:getCharacters')
-- AddEventHandler('desync-multichar:getCharacters', function()
--     local source = source
--     local baseIdentifier = string.match(GetPlayerIdentifier(source), ":(.*)")
    
--     print("^3[desync-multichar] Getting characters for source: " .. source .. "^7")
--     print("^3[desync-multichar] Base identifier: " .. tostring(baseIdentifier) .. "^7")
    
--     if not baseIdentifier then
--         print("^1[desync-multichar] Failed to get identifier for player " .. source .. "^7")
--         TriggerClientEvent('desync-multichar:setCharacters', source, {})
--         return
--     end
    
--     -- Search for any character number (char1, char2, etc.)
--     print("^3[desync-multichar] Querying database for characters^7")
--     local result = MySQL.query.await('SELECT * FROM Users WHERE Identifier LIKE ?', {'char%:' .. baseIdentifier})
--     print("^3[desync-multichar] Database query result: " .. json.encode(result) .. "^7")
    
--     if not result or #result == 0 then
--         print("^3[desync-multichar] No characters found for identifier: " .. baseIdentifier .. "^7")
--         result = {}
--     end
    
--     -- Process results to ensure each character has an ID
--     for _, char in ipairs(result) do
--         if not char.id then
--             char.id = char.Identifier
--         end
--     end
    
--     print("^3[desync-multichar] Sending characters to client^7")
--     TriggerClientEvent('desync-multichar:setCharacters', source, result)
-- end)

-- Create new character
RegisterNetEvent('desync-multichar:createCharacter')
AddEventHandler('desync-multichar:createCharacter', function(data)
    local source = source
    local baseIdentifier = string.match(GetPlayerIdentifier(source), ":(.*)")

    if not data.firstname or not data.lastname then
        TriggerClientEvent('desync-multichar:createCharacterResponse', source, { 
            success = false, 
            error = "First name and last name are required" 
        })
        return
    end
    
    -- Check for duplicate names
    local duplicateCheck = MySQL.query.await([[
        SELECT * FROM Users 
        WHERE FirstName = ? AND LastName = ? 
        AND Identifier LIKE ?
    ]], {
        data.firstname,
        data.lastname,
        'char%:' .. baseIdentifier
    })
    
    if duplicateCheck and #duplicateCheck > 0 then
        TriggerClientEvent('desync-multichar:createCharacterResponse', source, { 
            success = false, 
            error = "A character with this name already exists" 
        })
        return
    end
    
    -- Get the current highest character number for this player
    local result = MySQL.query.await('SELECT Identifier FROM Users WHERE Identifier LIKE ?', {'char%:' .. baseIdentifier})
    
    -- If no characters exist, start with char1, otherwise increment highest number
    local nextCharNum = 1
    if result and #result > 0 then
        for _, row in ipairs(result) do
            local charNum = tonumber(string.match(row.Identifier, "char(%d+):"))
            if charNum and charNum >= nextCharNum then
                nextCharNum = charNum + 1
            end
        end
    end
    
    -- Create new identifier with character number
    local newIdentifier = string.format("char%d:%s", nextCharNum, baseIdentifier)
    
    -- Default position for new characters
    local defaultPosition = json.encode({x = -269.4, y = -955.3, z = 31.2})
    
    -- Insert the new character into the database
    local success = MySQL.query.await([[
        INSERT INTO Users 
        (Identifier, FirstName, LastName, LastPosition) 
        VALUES (?, ?, ?, ?)
    ]], {
        newIdentifier,
        data.firstname,
        data.lastname,
        defaultPosition
    })
    
    if success then
        print("^2[desync-multichar] Created new character: " .. newIdentifier .. "^7")
        TriggerClientEvent('desync-multichar:createCharacterResponse', source, { 
            type = 'createCharacterResponse', 
            success = true 
        })
        Wait(500)
        local result = MySQL.query.await('SELECT * FROM Users WHERE Identifier LIKE ?', {'char%:' .. baseIdentifier})
        TriggerClientEvent('desync-multichar:setCharacters', source, result or {})
    else
        print("^1[desync-multichar] Failed to create character for: " .. newIdentifier .. "^7")
        TriggerClientEvent('desync-multichar:createCharacterResponse', source, { 
            type = 'createCharacterResponse', 
            success = false, 
            error = "Failed to create character" 
        })
    end
end)


-- Delete character
RegisterNetEvent('desync-multichar:deleteCharacter')
AddEventHandler('desync-multichar:deleteCharacter', function(characterId)
    local source = source
    local baseIdentifier = string.match(GetPlayerIdentifier(source), ":(.*)")
    print("^3[desync-multichar] Deleting character: " .. characterId .. "^7")
    
    MySQL.query.await('DELETE FROM Users WHERE Identifier = ?', {characterId})
    
    local result = MySQL.query.await('SELECT * FROM Users WHERE Identifier LIKE ?', {'char%:' .. baseIdentifier})
    TriggerClientEvent('desync-multichar:setCharacters', source, result or {})
end)

-- Update CharacterSelected event
RegisterNetEvent('desync-multichar:CharacterSelected')
AddEventHandler('desync-multichar:CharacterSelected', function(characterId)
    local source = source
    
    -- Your existing character loading logic here
    
    -- Instead of using LastPosition, use the provided spawn coordinates
    TriggerEvent("desync-core-rp:OnPlayerJoined", source, characterId)

    -- if spawnCoords then
    --     TriggerEvent("desync-spawnmanager:SpawnCharacter", source, spawnCoords)
    -- end
end)

-- Add this at the top of your server.lua
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    deferrals.update("Checking player information...")
    
    -- Add any additional checks here if needed
    
    deferrals.done()
end)

-- Add this to handle when player fully connects
AddEventHandler('playerJoining', function(oldId, newId)
    local source = source
    -- Trigger character selection as soon as they're ready
    TriggerClientEvent("desync-multichar:DisplayCharacterSelection", source)
end)

-- Add cleanup for disconnected players
AddEventHandler('playerDropped', function()
    local source = source
    if playerBuckets[source] then
        SetPlayerRoutingBucket(source, 0)
        playerBuckets[source] = nil
    end
end)