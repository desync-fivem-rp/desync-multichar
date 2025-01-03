lib.callback.register("desync-multichar2:getCharacters", function(source, userId)
    local source = source
    local result = MySQL.query.await("SELECT * FROM Characters WHERE userId = ? AND deleted IS NULL", {userId})
    return result
end)

RegisterNetEvent("desync-multichar2:createCharacter")
AddEventHandler("desync-multichar2:createCharacter", function(data, userId)
    local source = source

    -- call ox_core createPlayer
    local playerData = {
        firstName = data.firstName,
        lastName = data.lastName,
        gender = data.gender,
        date = data.dateOfBirth
    }

    local player = Ox.GetPlayer(source)
    local index = player.createCharacter(playerData)

    local result = nil
    while result == nil do
        result = MySQL.query.await("SELECT * FROM Characters WHERE userId = ? AND deleted IS NULL ORDER BY charId DESC LIMIT 1", {userId})
        Citizen.Wait(100)
    end
    
    -- local result = nil
    -- while result == nil do
    --     result = MySQL.query.await("SELECT * FROM Characters WHERE userId = ? AND deleted IS NULL", {userId})
    --     Citizen.Wait(100)
    -- end

    TriggerClientEvent("desync-multichar:OnCharacterCreation", source, result[1].charId)
    -- TriggerClientEvent('desync-multichar2:setCharacters', source, result or {})
end)

RegisterNetEvent('desync-multichar2:deleteCharacter')
AddEventHandler('desync-multichar2:deleteCharacter', function(characterId)
    local source = source
    local player = Ox.GetPlayer(source)
    local success = player.deleteCharacter(characterId)

    local result = nil

    while result == nil do
        result = MySQL.query.await("SELECT * FROM Characters WHERE userId = ? AND deleted IS NULL", {userId})
        Citizen.Wait(100)
    end
    
    TriggerClientEvent('desync-multichar2:setCharacters', source, result)
end)

function CreateNewBucket()

end

-- RegisterNetEvent("desync-multichar2:Init")
-- AddEventHandler("desync-multichar2:Init", function()
--     local netId = source

--     print('netId: ' .. netId)

--     local success, bucketId = lib.callback.await("desync-core:AddPlayerToNextAvailableRoutingBucket", false, netId)

--     print('1')

--     if not success then
--         print("Failed to add player to routing bucket")
--         return
--     end

--     print(success)
--     print(bucketId)

--     print("Added player to routing bucket: " .. GetPlayerRoutingBucket(netId))
-- end)

RegisterNetEvent("desync-multichar2:Cleanup")
AddEventHandler("desync-multichar2:Cleanup", function()
    local netId = source

    local success = lib.callback.await("desync-core:SetPlayerToDefaultRoutingBucket", false, netId)

    print("Current player routing bucket: " .. GetPlayerRoutingBucket(netId))
end)