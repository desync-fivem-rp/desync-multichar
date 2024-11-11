-- Add this at the top of your client.lua
local firstSpawn = true

-- Add these variables at the top with other locals
local isRotatingCamera = false
local lastMouseX = 0
local currentCamRotation = 0.0
local activeCam = nil

-- Add these constants at the top of the file
local CHARACTER_ROOM = {
    coords = vector3(915.4648, 51.8233, 114.0158), -- Starting camera position
    heading = 250.6621, -- Adjusted heading to face the correct way
    
    -- Add positions table for character peds
    positions = {
        {
            coords = vector3(911.6921, 53.7663, 111.1264),
            heading = 125.1907,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(910.8527, 51.2711, 111.1264),
            heading = 26.4501,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(909.4823, 51.0214, 111.1273),
            heading = 344.3992,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(910.5148, 54.6012, 111.1265),
            heading = 165.6402,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(906.8790, 53.8894, 111.2616),
            heading = 242.5208,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        },
        {
            coords = vector3(912.2040, 54.1265, 111.6119),
            heading = 304.3833,
            animation = {dict = "timetable@jimmy@mics3_ig_15@", anim = "idle_a_jimmy"}
        }
    },
    
    -- Camera positions
    cameras = {
        overview = {
            coords = vector3(915.4648, 51.8233, 114.0158),
            point = vector3(910.4648, 51.8233, 112.1264), -- Adjusted to point at the center of the sitting area
            fov = 60.0
        },
        character = {
            offset = vector3(1.0, 1.0, 0.5),
            fov = 40.0
        }
    }
}

AddEventHandler('onClientMapStart', function()
    if firstSpawn then
        firstSpawn = false
        
        -- Disable HUD
        DisplayHud(false)
        DisplayRadar(false)
        
        -- Trigger character selection
        TriggerEvent("desync-multichar:DisplayCharacterSelection")
    end
end)

-- Add these new functions at the top
local function SetupCharacterRoom()
    local ped = PlayerPedId()
    
    -- Teleport player to loading coords (out of view)
    SetEntityCoords(ped, CHARACTER_ROOM.coords.x, CHARACTER_ROOM.coords.y, CHARACTER_ROOM.coords.z - 10.0)
    
    -- Hide player
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)
    
    -- Set up initial camera
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local overview = CHARACTER_ROOM.cameras.overview
    
    SetCamCoord(cam, overview.coords.x, overview.coords.y, overview.coords.z)
    PointCamAtCoord(cam, overview.point.x, overview.point.y, overview.point.z)
    SetCamFov(cam, overview.fov)
    SetCamRot(cam, 0.0, 0.0, CHARACTER_ROOM.heading, 2)
    
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1000, true, true)
    
    -- Store the active camera
    activeCam = cam
    
    return cam
end

local characterPeds = {}

local function SetupCharacterPeds(characters)
    -- print("^3[desync-multichar] Setting up character peds with data:", json.encode(characters))
    
    -- Clear existing peds
    for _, pedInfo in pairs(characterPeds) do
        if DoesEntityExist(pedInfo.ped) then
            DeleteEntity(pedInfo.ped)
            DeletePed(pedInfo.ped)
        end
    end
    characterPeds = {}
    
    -- Safety check for characters
    if not characters or type(characters) ~= "table" then
        -- print("^1[desync-multichar] No valid characters data provided^7")
        return
    end
    
    -- Create new peds for each character
    for i, character in ipairs(characters) do
        if CHARACTER_ROOM.positions[i] then
            local position = CHARACTER_ROOM.positions[i]
            
            -- Safety check for character ID
            if not character.id then
                -- print("^1[desync-multichar] Character missing ID at index " .. i .. "^7")
                goto continue
            end
            
            -- print("^3[desync-multichar] Creating ped for character:", json.encode(character))
            
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
            characterPeds[character.id] = {
                ped = ped,
                position = position
            }
            
            ::continue::
        end
    end
    
    SetModelAsNoLongerNeeded(model)
end

local function FocusOnCharacter(characterId)
    local pedInfo = characterPeds[characterId]
    if not pedInfo then return end
    
    -- Create new camera
    local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local offset = CHARACTER_ROOM.cameras.character.offset
    local pedCoords = GetEntityCoords(pedInfo.ped)
    
    -- Position camera relative to ped
    local camCoords = vector3(
        pedCoords.x - offset.x,
        pedCoords.y - offset.y,
        pedCoords.z + offset.z
    )
    
    SetCamCoord(newCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(newCam, pedInfo.ped, 0.0, 0.0, 0.0, true)
    SetCamFov(newCam, CHARACTER_ROOM.cameras.character.fov)
    
    -- Smooth transition to new camera
    SetCamActiveWithInterp(newCam, activeCam, 1000, true, true)
    
    -- Update active camera
    activeCam = newCam
    
    return newCam
end

-- Update your existing ShowCharacterSelect function
local function ShowCharacterSelect()
    -- Hide HUD elements
    DisplayHud(false)
    DisplayRadar(false)
    
    -- Set up the character room
    local cam = SetupCharacterRoom()
    
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

-- Update the character selection display event
RegisterNetEvent("desync-multichar:DisplayCharacterSelection")
AddEventHandler("desync-multichar:DisplayCharacterSelection", function()
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
    TriggerServerEvent('desync-multichar:getCharacters')
end)

-- Update the character data event handler
RegisterNetEvent('desync-multichar:setCharacters')
AddEventHandler('desync-multichar:setCharacters', function(dbCharacters)
    if not dbCharacters then return end
    
    -- print("^3[desync-multichar] Setting up characters^7")
    
    -- Store characters for later use
    characters = dbCharacters
    
    -- Set up the peds immediately when we get the character data
    SetupCharacterPeds(dbCharacters)
    
    -- Send to NUI
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
    -- print("^2[desync-multichar] Selected character: " .. data.characterId .. "^7")
    SetNuiFocus(false, false)
    -- Add your character spawn logic here


	TriggerServerEvent("desync-multichar:CharacterSelected", data.characterId)
    cb({})
end)

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
    if not data.characterId then return cb({ success = false }) end
    
    -- Hide character select UI
    SendNUIMessage({
        type = 'ui',
        status = false
    })

    -- Show spawn selection UI and pass character ID
    TriggerEvent("desync-spawnselect:ShowUI", data.characterId)
    
    cb({success = true})
end)

-- Add new NUI callback
RegisterNUICallback('focusCharacter', function(data, cb)
    FocusOnCharacter(data.characterId)
    cb({})
end)

-- Add this function to handle camera rotation
local function UpdateCameraRotation()
    -- Only update if we're rotating
    if not isRotatingCamera or not activeCam then return end
    
    -- Get current mouse position
    local mouseX, _ = GetNuiCursorPosition()
    local mouseDelta = mouseX - lastMouseX
    lastMouseX = mouseX
    
    -- Update rotation (adjust sensitivity by changing the division factor)
    currentCamRotation = currentCamRotation + (mouseDelta / 10)
    
    -- Calculate new camera position based on rotation
    local radius = 4.0 -- Distance from center point
    local centerPoint = CHARACTER_ROOM.coords
    local camHeight = 1.0 -- Height offset from center
    
    local newX = centerPoint.x + (radius * math.cos(math.rad(currentCamRotation)))
    local newY = centerPoint.y + (radius * math.sin(math.rad(currentCamRotation)))
    
    -- Update camera
    SetCamCoord(activeCam, newX, newY, centerPoint.z + camHeight)
    PointCamAtCoord(activeCam, centerPoint.x, centerPoint.y, centerPoint.z)
end


-- Add cleanup function
local function CleanupCharacterSelect()
    print("^3[desync-multichar] Cleaning up character select^7")
    
    -- Reset camera
    if activeCam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(activeCam, true)
        activeCam = nil
    end
    
    -- Clean up peds
    for _, pedInfo in pairs(characterPeds) do
        if pedInfo and pedInfo.ped then
            print("^3[desync-multichar] Cleaning up ped: " .. tostring(pedInfo.ped) .. "^7")
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
    print("^3[desync-multichar] Resource stopping, cleaning up^7")
    CleanupCharacterSelect()
end)

-- Update spawn selection to NOT spawn peds (since they're already spawned)
RegisterNetEvent("desync-spawnselect:ShowUI")
AddEventHandler("desync-spawnselect:ShowUI", function(characterId)
    -- Store the character ID
    selectedCharId = characterId
    
    -- Show the spawn selection UI
    SetNuiFocus(true, true)
    TriggerServerEvent("desync-spawnselect:getSpawnPoints")
    SendNUIMessage({
        type = 'ui',
        status = true
    })
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

    -- Spawn at selected location
    if data.coords then
        TriggerServerEvent("desync-multichar:CharacterSelected", selectedCharId, data.coords)
    end
    
    selectedCharId = nil
    cb({success = true})
end)

-- Add ESC key handler
CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 200) then -- ESC key
            SendNUIMessage({
                type = 'ui',
                status = false
            })
            CleanupCharacterSelect()
            SetNuiFocus(false, false)
        end
    end
end)

-- Add this event handler for when character spawns
RegisterNetEvent("desync-multichar:CharacterSpawned")
AddEventHandler("desync-multichar:CharacterSpawned", function()
    -- Make sure camera is cleaned up
    if activeCam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(activeCam, true)
        activeCam = nil
    end
    
    -- Make sure player is visible and unfrozen
    local ped = PlayerPedId()
    SetEntityVisible(ped, true)
    FreezeEntityPosition(ped, false)
end)

-- Add this event handler for cleanup
RegisterNetEvent("desync-multichar:cleanup")
AddEventHandler("desync-multichar:cleanup", function()
    print("^3[desync-multichar] Cleanup triggered from spawn selection^7")
    CleanupCharacterSelect()
end)
