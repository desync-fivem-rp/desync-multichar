local characterPeds = {}
local newCharacterPed = nil
local userId = nil
local activeCam = nil
local isRotatingCamera = false
local lastMouseX = 0
local currentCamRotation = 0.0

local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

RegisterCommand('show-nui', function()
    Init()
    -- toggleNuiFrame(true)
    -- debugPrint('Show NUI frame')
end)

RegisterNUICallback('hideFrame', function(_, cb)
    toggleNuiFrame(false)
    debugPrint('Hide NUI frame')
    cb({})
end)

RegisterNUICallback('getClientData', function(data, cb)
    debugPrint('Data sent by React', json.encode(data))

    -- Lets send back client coords to the React frame for use
    local curCoords = GetEntityCoords(PlayerPedId())

    local retData <const> = { x = curCoords.x, y = curCoords.y, z = curCoords.z }
    cb(retData)
end)

RegisterNUICallback('characterSelected', function(data, cb)
    toggleNuiFrame(false)

    -- print('fading screen out')
    -- DoScreenFadeOut(500)
    -- Citizen.Wait(500)

    SwitchOutPlayer(cache.ped, 1 + 8192, 1)

    CleanupCharacterSelect()

    TriggerServerEvent("ox:setActiveCharacter", data.charId)

    TriggerEvent("desync-spawnselect:ShowUI", data.charId)

    cb({success = true})
end)

RegisterNUICallback('focusOnCharacterOverview', function(data, cb)
    FocusOnCharacterOverview()
    cb({})
end)

RegisterNUICallback('focusOnCharacter', function(data, cb)
    FocusOnCharacter(data.charId)
    cb({})
end)

RegisterNUICallback('focusOnNewCharacter', function(data, cb)
    FocusOnNewCharacter()
    cb({})
end)

RegisterNUICallback('deleteCharacter', function(data, cb)
    TriggerServerEvent("desync-multichar2:deleteCharacter", data.charId)
    cb({})
end)

RegisterNUICallback('createCharacter', function(data, cb)
    local eventId = math.random(1, 1000)
    TriggerServerEvent("desync-multichar2:createCharacter", data, userId)
    -- TriggerServerEvent("desync-test:ayo", eventId)
    cb({})
end)

RegisterNetEvent('desync-multichar2:setCharacters')
AddEventHandler('desync-multichar2:setCharacters', function(dbCharacters)    
    -- Store characters for later use
    characters = dbCharacters

    DisplayCharacterSelection()
    
    -- Set up the peds immediately when we get the character data
    -- SetupCharacterPeds(dbCharacters)
    
    -- Send to NUI
    -- SendNUIMessage({
    --     type = 'setCharacters',
    --     characters = dbCharacters
    -- })
end)

function Init()
    while not NetworkIsPlayerActive(PlayerId()) do
        print("NetworkIsPlayerActive is false")
        Citizen.Wait(100)
    end

    local success, bucketId = lib.callback.await("desync-core:AddSelfToNextAvailableRoutingBucket", false)

    if not success then
        print("Failed to add player to routing bucket")
        return
    end

    DoScreenFadeOut(100)

    -- Make the camera fly up in the air
    -- SwitchOutPlayer(cache.ped, 1 + 8192, 1)

    -- Get player userId from ox_core
    while not userId do
        local player = exports["ox_core"]:GetPlayer()
        userId = player.userId

        Citizen.Wait(500)
    end

    SetupNewCharacterPed()

    -- Display character selection
    DisplayCharacterSelection()

    -- Fade the screen in after we set up the scene
    DoScreenFadeIn(500)
end

function DisplayCharacterSelection()
    local result = lib.callback.await("desync-multichar2:getCharacters", false, userId)

    -- The player has no created characters (add logic here if you want)
    if #result == 0 then
        print("Player has no created characters")
    end

    -- SwitchInPlayer(PlayerPedId());
    SetGameplayCamRelativeHeading(0);

    -- Set up character selection
    SetupCharacterRoom()
    
    -- Disable HUD and radar before showing UI
    DisplayHud(false)
    DisplayRadar(false)
    
    -- Make sure NUI focus is properly set with both mouse and keyboard input
    SetNuiFocus(true, true)
    
    -- Set cursor to center of screen
    -- SetCursorLocation(0.5, 0.5)
    
    -- Show UI with full screen resolution
    -- local screenW, screenH = GetActiveScreenResolution()

    -- Send initial data
    local data = {
        maxCharacters = Config.MaxCharacters,
        characters = result
    }

    SendReactMessage('test', data)
    SendReactMessage('init', data)

    -- Set up character peds
    SetupCharacterPeds(result)

    -- Show UI
    toggleNuiFrame(true)
end

function SetupCharacterRoom()
    local ped = PlayerPedId()
    
    -- Teleport player to loading coords (out of view)
    SetEntityCoords(ped, Config.CHARACTER_ROOM.coords.x, Config.CHARACTER_ROOM.coords.y, Config.CHARACTER_ROOM.coords.z)
    
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
end

function FocusOnCharacter(characterId)
    local pedInfo = characterPeds[characterId]
    if not pedInfo then return end
    
    -- Create new camera
    local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local offset = Config.CHARACTER_ROOM.cameras.character.offset
    local pedCoords = GetEntityCoords(pedInfo.ped)
    
    -- Position camera relative to ped
    local camCoords = vector3(
        pedCoords.x - offset.x,
        pedCoords.y - offset.y,
        pedCoords.z + offset.z
    )
    
    SetCamCoord(newCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(newCam, pedInfo.ped, 0.0, 0.0, 0.0, true)
    SetCamFov(newCam, Config.CHARACTER_ROOM.cameras.character.fov)
    
    -- Smooth transition to new camera
    SetCamActiveWithInterp(newCam, activeCam, 1000, true, true)
    
    -- Update active camera
    activeCam = newCam
end

function SetupCharacterPeds(characters)
    if not characters then return end

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
        
        -- Safety check for character ID
        -- if not character.id then
        --     -- print("^1[desync-multichar] Character missing ID at index " .. i .. "^7")
        --     goto continue
        -- end
        
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
        characterPeds[character.charId] = {
            ped = ped,
            position = position
        }
            
            -- ::continue::
        -- end
    end
    
    SetModelAsNoLongerNeeded(model)
end

function CleanupCharacterSelect()
    -- Reset camera
    if activeCam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(activeCam, true)
        activeCam = nil
    end
    
    -- Clean up peds
    for _, pedInfo in pairs(characterPeds) do
        if pedInfo and pedInfo.ped then
            if DoesEntityExist(pedInfo.ped) then
                DeleteEntity(pedInfo.ped)
                SetEntityAsNoLongerNeeded(pedInfo.ped)
                DeletePed(pedInfo.ped)
            end
        end
    end
    characterPeds = {}
    newCharacterPed = {}
    
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

function SetupNewCharacterPed()
    local model = GetHashKey("mp_m_freemode_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local config = Config.NEW_CHARACTER
    local position = {
        coords = config.coords,
        heading = config.heading,
        animation = config.animation
    }
    
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
    newCharacterPed = {
        ped = ped,
        position = position
    }
end

function FocusOnNewCharacter()
    local pedInfo = newCharacterPed

    -- Create new camera
    local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local offset = Config.CHARACTER_ROOM.cameras.character.offset
    local pedCoords = GetEntityCoords(pedInfo.ped)
    
    -- Position camera relative to ped
    local camCoords = vector3(
        pedCoords.x - offset.x,
        pedCoords.y - offset.y,
        pedCoords.z + offset.z
    )
    
    SetCamCoord(newCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(newCam, pedInfo.ped, 0.0, 0.0, 0.0, true)
    SetCamFov(newCam, Config.CHARACTER_ROOM.cameras.character.fov)
    
    -- Smooth transition to new camera
    SetCamActiveWithInterp(newCam, activeCam, 1000, true, true)
    
    -- Update active camera
    activeCam = newCam
end

function FocusOnCharacterOverview()
    -- Set up initial camera
    local newCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local overview = Config.CHARACTER_ROOM.cameras.overview
    
    SetCamCoord(newCam, overview.coords.x, overview.coords.y, overview.coords.z)
    PointCamAtCoord(newCam, overview.point.x, overview.point.y, overview.point.z)
    SetCamFov(newCam, overview.fov)
    SetCamRot(newCam, 0.0, 0.0, Config.CHARACTER_ROOM.heading, 2)
    
    SetCamActiveWithInterp(newCam, activeCam, 1000, true, true)
    RenderScriptCams(true, false, 1000, true, true)
    
    -- Store the active camera
    activeCam = newCam
end

Init()
