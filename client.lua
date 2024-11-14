-- Add this at the top of your client.lua
local firstSpawn = true
local isRotatingCamera = false
local lastMouseX = 0
local currentCamRotation = 0.0
local activeCam = nil
local characterPeds = {}

function Init()
    Citizen.CreateThread(function()
        while not NetworkIsPlayerActive(PlayerId()) do
            -- print("NetworkIsPlayerActive is false")
            Citizen.Wait(100)
        end
    
        DoScreenFadeOut(0)
        Citizen.Wait(2000)
        -- TriggerEvent("desync-multichar:DisplayCharacterSelection")
        DisplayCharacterSelection()
    end)
end

function DisplayCharacterSelection()
    -- Set up character selection
    SetupCharacterRoom()
    
    -- Disable HUD and radar before showing UI
    DisplayHud(false)
    DisplayRadar(false)
    
    -- Make sure NUI focus is properly set with both mouse and keyboard input
    SetNuiFocus(true, true)
    
    -- Set cursor to center of screen
    SetCursorLocation(0.5, 0.5)
    
    -- Show UI with full screen resolution
    local screenW, screenH = GetActiveScreenResolution()
    SendNUIMessage({
        type = 'ui',
        status = true,
        maxCharacters = 6,
        resolution = {
            width = screenW,
            height = screenH
        }
    })
    
    -- Request characters from server
    local result = lib.callback.await("desync-multichar:getCharacters", false)

    SetCharacters(result)
    -- TriggerServerEvent('desync-multichar:getCharacters')
end

function SetupCharacterRoom()
    local ped = PlayerPedId()
    
    -- Teleport player to loading coords (out of view)
    SetEntityCoords(ped, Config.CHARACTER_ROOM.coords.x, Config.CHARACTER_ROOM.coords.y, Config.CHARACTER_ROOM.coords.z - 10.0)
    
    -- Hide player
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)
    
    -- Set up initial camera
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local overview = Config.CHARACTER_ROOM.cameras.overview
    
    SetCamCoord(cam, overview.coords.x, overview.coords.y, overview.coords.z)
    PointCamAtCoord(cam, overview.point.x, overview.point.y, overview.point.z)
    SetCamFov(cam, overview.fov)
    SetCamRot(cam, 0.0, 0.0, Config.CHARACTER_ROOM.heading, 2)
    
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1000, true, true)
    
    -- Store the active camera
    activeCam = cam
    
    return cam
end

function FocusOnCharacter(characterId)
    local pedInfo = characterPeds[characterId]
    if not pedInfo then return end
    
    -- Create new camera
    local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local offset = Config.CHARACTER_ROOM.cameras.character.offset
    local pedCoords = GetEntityCoords(pedInfo.ped)
    local pedHeading = pedInfo.position.heading
    
    -- Calculate camera position based on ped's heading
    -- Convert heading to radians and adjust for FiveM's heading system
    local headingRad = math.rad((pedHeading + 90) % 360)
    
    -- Calculate camera position using trigonometry
    local camCoords = vector3(
        pedCoords.x + (offset.x * math.cos(headingRad)),
        pedCoords.y + (offset.x * math.sin(headingRad)),
        pedCoords.z + offset.z
    )
    
    SetCamCoord(newCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(newCam, pedInfo.ped, 0.0, 0.3, 0.0, true)
    SetCamFov(newCam, Config.CHARACTER_ROOM.cameras.character.fov)
    
    -- Smooth transition to new camera
    SetCamActiveWithInterp(newCam, activeCam, 1000, true, true)
    
    -- Update active camera
    activeCam = newCam
    
    return newCam
end

------This function below works, just testing a different one
-- function FocusOnCharacter(characterId)
--     local pedInfo = characterPeds[characterId]
--     if not pedInfo then return end
    
--     -- Create new camera
--     local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
--     local offset = Config.CHARACTER_ROOM.cameras.character.offset
--     local pedCoords = GetEntityCoords(pedInfo.ped)
    
--     -- Position camera relative to ped
--     local camCoords = vector3(
--         pedCoords.x - offset.x,
--         pedCoords.y - offset.y,
--         pedCoords.z + offset.z
--     )
    
--     SetCamCoord(newCam, camCoords.x, camCoords.y, camCoords.z)
--     PointCamAtEntity(newCam, pedInfo.ped, 0.0, 0.0, 0.0, true)
--     SetCamFov(newCam, Config.CHARACTER_ROOM.cameras.character.fov)
    
--     -- Smooth transition to new camera
--     SetCamActiveWithInterp(newCam, activeCam, 1000, true, true)
    
--     -- Update active camera
--     activeCam = newCam
    
--     return newCam
-- end


function SetCharacters(dbCharacters)
    if not dbCharacters then
        print("No characters found or something")
        return 
    end
    
    
    -- Set up the peds immediately when we get the character data
    SetupCharacterPeds(dbCharacters)
    
    -- Send to NUI
    SendNUIMessage({
        type = 'setCharacters',
        characters = dbCharacters
    })
end

function SetupCharacterPeds(characters)    
    -- Clear existing peds
    for _, pedInfo in pairs(characterPeds) do
        if DoesEntityExist(pedInfo.ped) then
            DeleteEntity(pedInfo.ped)
            DeletePed(pedInfo.ped)
        end
    end

    characterPeds = {}
    
    -- Create new peds for each character
    for i, character in ipairs(characters) do
        -- if Config.CHARACTER_ROOM.positions[i] then
        local position = Config.CHARACTER_ROOM.positions[i]
        
        -- Create ped
        local model = GetHashKey("mp_m_freemode_01")
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end
        
        local ped = CreatePed(4, model, 
            position.coords.x, position.coords.y, position.coords.z, 
            position.heading, false, true)
            
        -- Set up ped
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        -- Apply animation if specified
        if position.animation then
            RequestAnimDict(position.animation.dict)
            while not HasAnimDictLoaded(position.animation.dict) do Wait(0) end
            
            TaskPlayAnim(ped, 
                position.animation.dict, position.animation.anim,
                8.0, -8.0, -1, 1, 0, false, false, false)
        end
        
        -- Store ped reference
        characterPeds[character.Identifier] = {
            ped = ped,
            position = position
        }
            
            -- ::continue::
        -- end
    end
    
    SetModelAsNoLongerNeeded(model)
end


-- Test command
RegisterCommand('testcharselect', function()
    DisplayCharacterSelection()
    -- ShowCharacterSelect()
end, false)


RegisterNUICallback('desync-multichar:hideui', function(_, cb)
    -- print("^2[desync-multichar] Hiding UI^7")
    SetNuiFocus(false, false)
    cb({})
end)

-- Update these callbacks to match the fetchNui event names
RegisterNUICallback('getCharacters', function(data, cb)
    TriggerServerEvent('desync-multichar:getCharacters')
    cb({})
end)

RegisterNUICallback('createCharacter', function(data, cb)
    -- print("^2[desync-multichar] Creating character^7")
    TriggerServerEvent('desync-multichar:createCharacter', data)
    cb({ success = true })
end)

-- Add new event handler for character creation response
RegisterNetEvent('desync-multichar:createCharacterResponse')
AddEventHandler('desync-multichar:createCharacterResponse', function(response)
    -- print("^2[desync-multichar] Character creation response:", json.encode(response))
    SendNUIMessage({
        type = 'characterCreated',
        success = response.success
    })
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent('desync-multichar:deleteCharacter', data.characterId)
    cb({})
end)


-- Add new NUI callback
RegisterNUICallback('focusCharacter', function(data, cb)
    FocusOnCharacter(data.characterId)
    cb({})
end)


-- Add cleanup function
local function CleanupCharacterSelect()
    -- print("^3[desync-multichar] Cleaning up character select^7")
    
    -- Reset camera
    if activeCam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(activeCam, true)
        activeCam = nil
    end
    
    -- Clean up peds
    for _, pedInfo in pairs(characterPeds) do
        if pedInfo and pedInfo.ped then
            -- print("^3[desync-multichar] Cleaning up ped: " .. tostring(pedInfo.ped) .. "^7")
            if DoesEntityExist(pedInfo.ped) then
                DeleteEntity(pedInfo.ped)
                SetEntityAsNoLongerNeeded(pedInfo.ped)
                DeletePed(pedInfo.ped)
            end
        end
    end
    characterPeds = {}
    
    -- Reset state variables
    selectedCharId = nil
    currentCamRotation = 0.0
    
    -- Make player visible again
    local ped = PlayerPedId()
    SetEntityVisible(ped, true)
    FreezeEntityPosition(ped, false)
    
    -- Re-enable HUD elements
    DisplayHud(true)
    DisplayRadar(true)
end

-- Make sure cleanup happens when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    -- print("^3[desync-multichar] Resource stopping, cleaning up^7")
    CleanupCharacterSelect()
end)


-- Clean up peds when spawn is selected
RegisterNUICallback('spawnAtLocation', function(data, cb)
    -- print("^2[desync-multichar] Spawning at location^7")
    SetNuiFocus(false, false)
    
    -- Clean up peds and camera
    CleanupCharacterSelect()
    
    -- Hide UI
    SendNUIMessage({
        type = 'ui',
        status = false
    })
    
    selectedCharId = nil
    cb({success = true})
end)



-- Add this event handler for cleanup
RegisterNetEvent("desync-multichar:cleanup")
AddEventHandler("desync-multichar:cleanup", function()
    -- print("^3[desync-multichar] Cleanup triggered from spawn selection^7")
    CleanupCharacterSelect()
end)

RegisterNUICallback('switchToSpawnSelect', function(data, cb)
    if not data.characterId then
        return cb({ success = false })
    end
    
    -- Hide character select UI
    SendNUIMessage({
        type = 'ui',
        status = false
    })

    SetNuiFocus(false, false)
    
    -- Trigger spawn selection UI
    TriggerEvent("desync-spawnselect:ShowUI", data.characterId)
    
    cb({success = true})
end)

Init()