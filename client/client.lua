local vehicleHUDActive = false
local playerHUDActive = false
local hunger = 100
local thirst = 100
local seatbeltOn = false
local showSeatbelt = false
local showAltitude = false

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(500)
    startHUD()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(500)
    startHUD()
end)

function startHUD()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped) then DisplayRadar(false) else DisplayRadar(true) SendNUIMessage({ action = 'showVehicleHUD' }) end
    TriggerEvent('hud:client:LoadMap')
    SendNUIMessage({ action = 'showPlayerHUD' })
    playerHUDActive = true
    loadPlayerNeeds()
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

function getCrossroads(vehicle)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(vehicle)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)     
        --print(street1) -- Usado para pegar Hash da rua  
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return lastCrossroadCheck
end

CreateThread(function()
    while true do
        local stamina = 0
        local playerId = PlayerId()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if not IsPauseMenuActive() then
            if not playerHUDActive then SendNUIMessage({ action = 'showPlayerHUD' }) end
            if not IsEntityInWater(player) then stamina = (100 - GetPlayerSprintStaminaRemaining(playerId)) end
            if IsEntityInWater(player) then stamina = (GetPlayerUnderwaterTimeRemaining(playerId) * 10) end
            SendNUIMessage({
                action = 'updatePlayerHUD',
                health = (GetEntityHealth(ped) - 100),
                armor = GetPedArmour(ped),
                thirst = thirst,
                hunger = hunger,
                stamina = stamina,
                voice = LocalPlayer.state['proximity'].distance,
                
                talking = NetworkIsPlayerTalking(PlayerId()),
            })
            if IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped) then
                if not vehicleHUDActive then
                    vehicleHUDActive = true
                    DisplayRadar(true)
                    TriggerEvent('hud:client:LoadMap')
                    SendNUIMessage({ action = 'showVehicleHUD' })
                end
                local crossroads = getCrossroads(vehicle)
                SendNUIMessage({
                    action = 'updateVehicleHUD',
                    speed = math.ceil(GetEntitySpeed(vehicle) * Config.speedMultiplier),
                    fuel = math.ceil(GetVehicleFuelLevel(vehicle)),
                    gear = GetVehicleCurrentGear(vehicle),
                    street1 = crossroads[1],
                    street2 = crossroads[2],
                    direction = GetDirectionText(GetEntityHeading(vehicle)),
                    seatbelt = seatbeltOn,
                    -- GetEntityCoords(player).z * 0.5
                    altitude = math.ceil(GetEntityCoords(ped).z * 0.5),
                    altitudetexto = "ALT"
                })

            else if IsPedInAnyVehicle(ped) then
                    if not vehicleHUDActive then
                        vehicleHUDActive = true
                        DisplayRadar(true)
                        TriggerEvent('hud:client:LoadMap')
                        SendNUIMessage({ action = 'showVehicleHUD' })
                    end
                    local crossroads = getCrossroads(vehicle)
                    local selectedgear = getSelectedGear()
                    local gearlol = getinfo(selectedgear)
                    SendNUIMessage({
                        action = 'updateVehicleHUD',
                        speed = math.ceil(GetEntitySpeed(vehicle) * Config.speedMultiplier),
                        fuel = math.ceil(GetVehicleFuelLevel(vehicle)),
                        gear = gearlol,
                        street1 = crossroads[1],
                        street2 = crossroads[2],
                        direction = GetDirectionText(GetEntityHeading(vehicle)),
                        seatbelt = seatbeltOn,
                        altitude = "",
                        altitudetexto = ""

                    })
                    else if vehicleHUDActive then vehicleHUDActive = false DisplayRadar(false) SendNUIMessage({ action = 'hideVehicleHUD' }) end end
            end

            --[[
                
            Citizen.CreateThread(function()
                while true do
                    local player = GetPlayerPed(-1)
                    local vehicle = GetVehiclePedIsIn(player, false)

                    if IsPedInAnyVehicle(player, false) then
                    --print("is a car beu")
                        local rpmlol = GetVehicleCurrentRpm(vehicle)
                        local selectedgear = getSelectedGear()
                        local gearlol = getinfo(selectedgear)
                        --print("RPM: " .. rpm)  -- Debugging line

                        SendNUIMessage({
                            rpm = rpmlol,
                            gear = gearlol
                        })
                    end
                    Citizen.Wait(100)
                end
            end)

            ]]--

        else
            vehicleHUDActive = false
            DisplayRadar(false)
            SendNUIMessage({ action = 'hideVehicleHUD' })
            SendNUIMessage({ action = 'hidePlayerHUD' })
            playerHUDActive = false
        end
        SetBigmapActive(false, false)
        SetRadarZoom(1000)
        Wait(Config.updateDelay)
    end
end)
/*
function GetDirectionText(heading)
    if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
        return "N"
    elseif (heading >= 45 and heading < 135) then
        return "W"
    elseif (heading >=135 and heading < 225) then
        return "S"
    elseif (heading >= 225 and heading < 315) then
        return "E"
    end
end
*/

function GetDirectionText(heading)
    if ((heading >= 0 and heading < 30) or (heading >= 330 and heading < 360)) then
        return "N"
    elseif (heading >= 30 and heading < 60) then
        return "NW"
    elseif (heading >= 60 and heading < 120) then
        return "W"
    elseif (heading >= 120 and heading < 160) then
        return "SW"
    elseif (heading >= 160 and heading < 210) then
        return "S"
    elseif (heading >= 210 and heading < 240) then
        return "SE"
    elseif (heading >= 240 and heading < 310) then
        return "E"
    elseif (heading >= 310 and heading < 330) then
        return "NE"
    end
end

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    thirst = newThirst
    hunger = newHunger
end)



AddEventHandler('seatbelt:client:ToggleSeatbelt', function(enable)
    seatbeltOn = enable 
    SendNUIMessage({action = 'setSeatbelt', seatbelt = seatbeltOn})
end)


RegisterNetEvent('hud:client:ToggleAirHud', function()
    showAltitude = not showAltitude
end)

RegisterNetEvent("hud:client:LoadMap", function()
    Wait(100)
    local defaultAspectRatio = 1920/1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local safezone = GetSafeZoneSize()
    local aspectRatio = (resolutionX-(safezone/2))/(resolutionY-(safezone/2))
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.019 end
    RequestStreamedTextureDict("squaremap", false)
    if not HasStreamedTextureDictLoaded("squaremap") then Wait(150) end
    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.065, 0.252, 0.338)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetMinimapClipType(0)
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
end)


Citizen.CreateThread(function()
    AddTextEntryByHash(-2068448071, 'Vespucci Blvd') -- Vespucci Boulevard
    AddTextEntryByHash(-1054680993, 'Moorningwood Blvd') -- Moorningwood Boulevard
    AddTextEntryByHash(1502743981, 'North Rockford Dr') -- North Rockford Drive
    AddTextEntryByHash(629262578, 'Blvd Del Perro') -- Boulevard Del Perro
    AddTextEntryByHash(30934387, 'South Rockford Dr') -- South Rockford Drive
    AddTextEntryByHash(-267870621, 'Las Lagunas Blvd') -- Las Lagunas Boulevard
    AddTextEntryByHash(776581733, 'Elysian Fields Fwy') -- Elysian Fields Freeway
    AddTextEntryByHash(-457429001, 'Miriam Turner Op') -- Miriam Turner Overpass
    AddTextEntryByHash(1989782134, 'South Shambless St') -- South Shambless Street
    AddTextEntryByHash(-701377429, 'Roy Lowenstein Blvd') -- Roy Lowenstein Boulevard
    AddTextEntryByHash(530762033, 'Mirror Park Blvd') -- Mirror Park Boulevard
    AddTextEntryByHash(-641602866, 'Mad Wayne Thunder Dr') -- Mad Wayne Thunder Drive
    AddTextEntryByHash(-13271429, 'Mad Wayne Thunder Dr') -- Mad Wayne Thunder Drive
    AddTextEntryByHash(1945677281, 'South Blvd Del Perro') -- South Boulevard Del Perro
    AddTextEntryByHash(1589412475, 'Mount Vinewood Dr') -- Mount Vinewood Drive
    AddTextEntryByHash(-1649175264, 'Little Bighorn Ave') -- Little Bighorn Avenue

    
    
end)