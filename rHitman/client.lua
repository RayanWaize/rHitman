local ESX = nil
local gangHitmanMoney = nil
local allTargetServer = {}

if Config.newESX then
    ESX = exports["es_extended"]:getSharedObject()
else
    Citizen.CreateThread(function()
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        while ESX == nil do Citizen.Wait(100) end
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
        ESX.PlayerData = ESX.GetPlayerData()
    end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

local function rHitmanKeyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local function getAllTarget()
    ESX.TriggerServerCallback('rHitman:getAllTarget', function(result)
        allTargetServer = result
    end)
end

RegisterNetEvent('rHitman:clientGetAllTarget')
AddEventHandler('rHitman:clientGetAllTarget', function()
	getAllTarget()
end)

local function menuF7()
    local menuP = RageUI.CreateMenu("Hitman", "Que voulez vous faire ?")
    local menuS = RageUI.CreateSubMenu(menuP, "Hitman", "Que voulez vous faire ?")
    RageUI.Visible(menuP, not RageUI.Visible(menuP))

    while menuP do
        Citizen.Wait(0)
        RageUI.IsVisible(menuP, true, true, true, function()

            RageUI.Separator("~b~Facture")

            RageUI.ButtonWithStyle("Facture",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local player, distance = ESX.Game.GetClosestPlayer()
                    local amount = rHitmanKeyboard("Montant de la facture ?", "", 10)
                    if tonumber(amount) then
                        if player ~= -1 and distance <= 3.0 then
                            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_hitman', ('Tueur à gages'), tonumber(amount))
                            TriggerEvent('esx:showAdvancedNotification', 'Fl~g~ee~s~ca ~g~Bank', 'Facture envoyée : ', 'Vous avez envoyé une facture d\'un montant de : ~g~'..amount..'$', 'CHAR_BANK_FLEECA', 9)
                        else
                            ESX.ShowNotification("~r~Probleme~s~: Aucuns joueurs proche")
                        end
                    else
                        ESX.ShowNotification("~r~Probleme~s~: Montant invalide")
                    end
                end
            end)

            RageUI.Separator("~o~Message")

            RageUI.ButtonWithStyle("Envoyer un message a l'équipe",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local msg = rHitmanKeyboard("Message ?", "", 60)
                    TriggerServerEvent("rHitman:sendMsgHitmans", msg)
                end
            end)

            RageUI.Separator("~r~Gestion des cibles")

            RageUI.ButtonWithStyle("Ouvrir le dossier",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    getAllTarget()
                end
            end, menuS)

        end)

        RageUI.IsVisible(menuS, true, true, true, function()

            RageUI.ButtonWithStyle("Ajouter une cible",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local nameOfTarget = rHitmanKeyboard("Nom complet de la cible ?", "", 50)
                    local ageOfTarget = rHitmanKeyboard("Âge de la cible ?", "", 10)
                    local numberPhoneOfTarget = rHitmanKeyboard("Numero de telephone de la cible ?", "", 80)
                    if nameOfTarget == nil then
                        ESX.ShowNotification("~r~Vous avez mal fait quelques choses !")
                    elseif ageOfTarget == nil then
                        ESX.ShowNotification("~r~Vous avez mal fait quelques choses !")
                    elseif numberPhoneOfTarget == nil then
                        ESX.ShowNotification("~r~Vous avez mal fait quelques choses !")
                    else
                        TriggerServerEvent("rHitman:addTarget", nameOfTarget, ageOfTarget, numberPhoneOfTarget)
                    end
                end
            end)

            RageUI.Line()

            RageUI.Separator("~r~Cibles")

            for k,v in pairs(allTargetServer) do
                RageUI.ButtonWithStyle("Cible #"..v.id, "→ ~r~Nom complet:~s~ "..v.nameTarget.."\n→ ~o~Age:~s~ "..v.ageTarget.."\n→ ~g~Numero tel:~s~ "..v.numTarget, {RightLabel = "→ ~r~Supprimer~s~"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        ESX.ShowNotification("Suppression en cours...")
                        TriggerServerEvent("rHitman:removeTarget", v.id)
                    end
                end)
            end

        end)
        if not RageUI.Visible(menuP) and not RageUI.Visible(menuS) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

Keys.Register('F7', 'Hitman', 'Ouvrir le menu hitman', function()
    if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == "hitman" then
        menuF7()
    end
end)

local function spawnCar(car)
    local carhash = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(carhash, Config.posSpawnCar, true, false)
    local plaque = "hitman"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
end

local function menuGarage()
    local menuGarageP = RageUI.CreateMenu("Garage", "Hitman")
        RageUI.Visible(menuGarageP, not RageUI.Visible(menuGarageP))
            while menuGarageP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuGarageP, true, true, true, function()

                RageUI.Separator("~g~↓ Véhicule disponible ↓")

                for k,v in pairs(Config.carInGarage) do
                    RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                        if Selected then
                            spawnCar(v.model)
                            RageUI.CloseAll()
                        end
                    end)
                end

                end)
            if not RageUI.Visible(menuGarageP) then
            menuGarageP = RMenu:DeleteType("menuGarageP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posMenuCar)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posMenuCar, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au garage", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuGarage()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local posDelete = vector3(Config.posSpawnCar.x, Config.posSpawnCar.y, Config.posSpawnCar.z)
        local dist = #(plyPos-posDelete)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posSpawnCar.x, Config.posSpawnCar.y, Config.posSpawnCar.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ranger la voiture", time_display = 1 })
            if IsControlJustPressed(1,51) then
                local veh, dist4 = ESX.Game.GetClosestVehicle()
                if dist4 < 4 then
                    DeleteEntity(veh)
                    RageUI.CloseAll()
                end
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


local function spawnHelico(car)
    local carhash = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(carhash, Config.posSpawnHelico, true, false)
    local plaque = "hitman"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
end

local function menuGarageHelico()
    local menuGarageP = RageUI.CreateMenu("Garage hélicoptère", "Hitman")
        RageUI.Visible(menuGarageP, not RageUI.Visible(menuGarageP))
            while menuGarageP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuGarageP, true, true, true, function()

                RageUI.Separator("~g~↓ Hélicoptère disponible ↓")

                for k,v in pairs(Config.helicoInGarage) do
                    RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                        if Selected then
                            spawnHelico(v.model)
                            RageUI.CloseAll()
                        end
                    end)
                end

                end)
            if not RageUI.Visible(menuGarageP) then
            menuGarageP = RMenu:DeleteType("menuGarageP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posMenuHelico)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posMenuHelico, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au garage", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuGarageHelico()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local posDelete = vector3(Config.posSpawnHelico.x, Config.posSpawnHelico.y, Config.posSpawnHelico.z)
        local dist = #(plyPos-posDelete)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posSpawnHelico.x, Config.posSpawnHelico.y, Config.posSpawnHelico.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ranger l'hélicoptère", time_display = 1 })
            if IsControlJustPressed(1,51) then
                local veh, dist4 = ESX.Game.GetClosestVehicle()
                if dist4 < 4 then
                    DeleteEntity(veh)
                    RageUI.CloseAll()
                end
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


local function spawnBoat(car, key)
    local carhash = GetHashKey(car)
    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(carhash, Config.posBoat.spawnPos[key], true, false)
    local plaque = "hitman"..math.random(1,9)
    SetVehicleNumberPlateText(vehicle, plaque)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
end

local function menuGarageBoat(key)
    local menuGarageP = RageUI.CreateMenu("Garage Bateau", "Hitman")
        RageUI.Visible(menuGarageP, not RageUI.Visible(menuGarageP))
            while menuGarageP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuGarageP, true, true, true, function()

                RageUI.Separator("~g~↓ Bateau(x) disponible ↓")

                for k,v in pairs(Config.boatInGarage) do
                    RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                        if Selected then
                            spawnBoat(v.model, key)
                            RageUI.CloseAll()
                        end
                    end)
                end

                end)
            if not RageUI.Visible(menuGarageP) then
            menuGarageP = RMenu:DeleteType("menuGarageP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        for k,v in pairs(Config.posBoat.menuPos) do
        local dist = #(plyPos-v)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, v, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au garage", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuGarageBoat(k)
            end
         end
        end
    end
    Citizen.Wait(Timer)
 end
end)

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        for k,v in pairs(Config.posBoat.spawnPos) do
        local posDelete = vector3(v.x, v.y, v.z)
        local dist = #(plyPos-posDelete)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour ranger le bateau", time_display = 1 })
            if IsControlJustPressed(1,51) then
                local veh, dist4 = ESX.Game.GetClosestVehicle()
                if dist4 < 4 then
                    DeleteEntity(veh)
                    SetEntityCoords(PlayerPedId(), Config.posBoat.menuPos[k])
                end
            end
         end
        end
    end
    Citizen.Wait(Timer)
 end
end)

local function menuCoffreRetirer()
    local menuCoffre = RageUI.CreateMenu("Coffre", "Hitman")
    ESX.TriggerServerCallback('rHitman:getStockItems', function(items) 
    RageUI.Visible(menuCoffre, not RageUI.Visible(menuCoffre))
        while menuCoffre do
            Citizen.Wait(0)
                RageUI.IsVisible(menuCoffre, true, true, true, function()
                        for k,v in pairs(items) do 
                            if v.count > 0 then
                            RageUI.ButtonWithStyle(v.label, nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local count = rHitmanKeyboard("Combien ?", "", 2)
                                    TriggerServerEvent('rHitman:getStockItem', v.name, tonumber(count))
                                    RageUI.CloseAll()
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(menuCoffre) then
            menuCoffre = RMenu:DeleteType("Coffre", true)
        end
    end
     end)
end


local function menuCoffreDeposer()
    local StockPlayer = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire")
    ESX.TriggerServerCallback('rHitman:getPlayerInventory', function(inventory)
        RageUI.Visible(StockPlayer, not RageUI.Visible(StockPlayer))
    while StockPlayer do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayer, true, true, true, function()
                for i=1, #inventory.items, 1 do
                    if inventory ~= nil then
                         local item = inventory.items[i]
                            if item.count > 0 then
                                    RageUI.ButtonWithStyle(item.label, nil, {RightLabel = item.count}, true, function(Hovered, Active, Selected)
                                            if Selected then
                                            local count = rHitmanKeyboard("Combien ?", '' , 8)
                                            TriggerServerEvent('rHitman:putStockItems', item.name, tonumber(count))
                                            RageUI.CloseAll()
                                        end
                                    end)
                                end
                            else
                                RageUI.Separator('Chargement en cours')
                            end
                        end
                    end, function()
                    end)
                if not RageUI.Visible(StockPlayer) then
                StockPlayer = RMenu:DeleteType("Coffre", true)
            end
        end
    end)
end


local function menuCoffreRetirerW()
    local StockCoffreWeapon = RageUI.CreateMenu("Coffre", "Hitman")
    ESX.TriggerServerCallback('rHitman:getArmoryWeapons', function(weapons)
    RageUI.Visible(StockCoffreWeapon, not RageUI.Visible(StockCoffreWeapon))
        while StockCoffreWeapon do
            Citizen.Wait(0)
                RageUI.IsVisible(StockCoffreWeapon, true, true, true, function()
                        for k,v in pairs(weapons) do
                            if v.count > 0 then
                            RageUI.ButtonWithStyle("~r~→~s~ "..ESX.GetWeaponLabel(v.name), nil, {RightLabel = v.count}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    ESX.TriggerServerCallback('rHitman:removeArmoryWeapon', function()
                                        RageUI.CloseAll()
                                    end, v.name)
                                end
                            end)
                        end
                    end
                end, function()
                end)
            if not RageUI.Visible(StockCoffreWeapon) then
            StockCoffreWeapon = RMenu:DeleteType("Coffre", true)
        end
    end
    end)
end

local function menuCoffreDeposerW()
    local StockPlayerWeapon = RageUI.CreateMenu("Coffre", "Voici votre ~y~inventaire d'armes")
        RageUI.Visible(StockPlayerWeapon, not RageUI.Visible(StockPlayerWeapon))
    while StockPlayerWeapon do
        Citizen.Wait(0)
            RageUI.IsVisible(StockPlayerWeapon, true, true, true, function()
                
                local weaponList = ESX.GetWeaponList()

                for i=1, #weaponList, 1 do
                    local weaponHash = GetHashKey(weaponList[i].name)
                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
                    RageUI.ButtonWithStyle("~r~→~s~ "..weaponList[i].label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                        ESX.TriggerServerCallback('rHitman:addArmoryWeapon', function()
                            RageUI.CloseAll()
                        end, weaponList[i].name, true)
                    end
                end)
            end
            end
            end, function()
            end)
                if not RageUI.Visible(StockPlayerWeapon) then
                StockPlayerWeapon = RMenu:DeleteType("Coffre", true)
            end
        end
end

local function menuCoffre()
    local menuP = RageUI.CreateMenu("Coffre", "Hitman")
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
            while menuP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()

                if Config.WeaponItems then

                    RageUI.Separator("~b~↓ Objet(s) / Arme(s) ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreRetirer()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreDeposer()
                        end
                    end)
                else
                    RageUI.Separator("~b~↓ Objet(s) ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreRetirer()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreDeposer()
                        end
                    end)

                    RageUI.Separator("~r~↓ Arme(s) ↓")

                    RageUI.ButtonWithStyle("Retirer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreRetirerW()
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("Déposer",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            RageUI.CloseAll()
                            menuCoffreDeposerW()
                        end
                    end)
                end
            end)
            if not RageUI.Visible(menuP) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posCoffre)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posCoffre, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 1.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au coffre", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuCoffre()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


local function menuArmory()
    local menuP = RageUI.CreateMenu("Armurerie", "Hitman")
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
            while menuP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()

                RageUI.ButtonWithStyle("Rendre tous les armes",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("rHitman:removeAllWeapons")
                    end
                end)

                RageUI.Separator("~g~↓ Arme(s) Disponible(s) ↓")

                for k,v in pairs(Config.weaponInArmory) do
                    RageUI.ButtonWithStyle(v.label, nil, {RightLabel = "→→"},true, function(Hovered, Active, Selected)
                        if Selected then
                            TriggerServerEvent("rHitman:addWeapon", v.weapon, v.label)
                            RageUI.CloseAll()
                        end
                    end)
                end

                end)
            if not RageUI.Visible(menuP) then
                menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posArmory)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posArmory, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder a l'armurerie", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuArmory()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posTpUp)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posTpUp, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour descendre", time_display = 1 })
            if IsControlJustPressed(1,51) then
                SetEntityCoords(PlayerPedId(), Config.posTpDown)
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posTpDown)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posTpDown, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour monter", time_display = 1 })
            if IsControlJustPressed(1,51) then
                SetEntityCoords(PlayerPedId(), Config.posTpUp)
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

local function setOutfit()
    TriggerEvent('skinchanger:getSkin', function(skin)
        local uniformObject
        if skin.sex == 0 then
            uniformObject = Config.uniform.maleWear
        else
            uniformObject = Config.uniform.femaleWear
        end
        if uniformObject then
            TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
        end
    end)
end

local function menuVestaire()
    local menuP = RageUI.CreateMenu("Vestaire", "Hitman")
        RageUI.Visible(menuP, not RageUI.Visible(menuP))
            while menuP do
            Citizen.Wait(0)
            RageUI.IsVisible(menuP, true, true, true, function()

                RageUI.ButtonWithStyle("Remettre sa tenue",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
                            TriggerEvent('skinchanger:loadSkin', skin)
                        end)
                    end
                end)

                RageUI.Separator("~g~↓ Tenue Hitman ↓")

                RageUI.ButtonWithStyle("Mettre",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        setOutfit()
                    end
                end)

                end)
            if not RageUI.Visible(menuP) then
                menuP = RMenu:DeleteType("menuP", true)
        end
    end
end


Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posVestaire)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posVestaire, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 3.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au vestaire", time_display = 1 })
            if IsControlJustPressed(1,51) then
                menuVestaire()
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)

local function UpdateSocietyMoney(money)
    gangHitmanMoney = ESX.Math.GroupDigits(money)
end

local function refreshMoney()
    if ESX.PlayerData.job2 ~= nil and ESX.PlayerData.job2.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateSocietyMoney(money)
        end, ESX.PlayerData.job2.name)
    end
end

local function menuBoss()
    local menuBossP = RageUI.CreateMenu("Actions Patron", "Hitman")
    RageUI.Visible(menuBossP, not RageUI.Visible(menuBossP))
    while menuBossP do
        Wait(0)
        RageUI.IsVisible(menuBossP, true, true, true, function()

            if gangHitmanMoney ~= nil then
                RageUI.Separator("~o~Argent société:~s~ ~g~"..gangHitmanMoney.."$")
            end

            RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = rHitmanKeyboard("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        ESX.ShowNotification("~r~Montant invalide")
                    else
                        TriggerServerEvent('esx_society:withdrawMoney', 'hitman', amount)
                        refreshMoney()
                    end
                end
            end)

            RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    local amount = rHitmanKeyboard("Montant", "", 10)
                    amount = tonumber(amount)
                    if amount == nil then
                        ESX.ShowNotification("~r~Montant invalide")
                    else
                        TriggerServerEvent('esx_society:depositMoney', 'hitman', amount)
                        refreshMoney()
                    end
                end
            end)

           RageUI.ButtonWithStyle("Accéder aux actions de Management",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    RageUI.CloseAll()
                    TriggerEvent('esx_society:openBossMenu', 'hitman', function(data, menu)
                        menu.close()
                    end, {wash = false})
                end
            end)
        end)
        if not RageUI.Visible(menuBossP) then
            menuBossP = RMenu:DeleteType("menuBossP", true)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        local plyPos = GetEntityCoords(PlayerPedId())
        local dist = #(plyPos-Config.posMenuBoss)
        if ESX.PlayerData.job2 and ESX.PlayerData.job2.name == 'hitman' and ESX.PlayerData.job2.grade_name == 'boss' then
        if dist <= 10.0 then
         Timer = 0
         DrawMarker(22, Config.posMenuBoss, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
        end
         if dist <= 1.0 then
            Timer = 0
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
            if IsControlJustPressed(1,51) then
                if Config.userMenuBoss then
                    if Config.allowWhiten then
                        TriggerEvent('rBossMenu:openMenuBoss', "hitman", true, true)
                    else
                        TriggerEvent('rBossMenu:openMenuBoss', "hitman", true, false)
                    end
                else
                    refreshMoney()
                    menuBoss()
                end
            end
         end
        end
    Citizen.Wait(Timer)
 end
end)