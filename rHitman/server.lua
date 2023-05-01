local ESX = nil

if Config.newESX then
    ESX = exports["es_extended"]:getSharedObject()
else
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

TriggerEvent('esx_society:registerSociety', 'hitman', 'hitman', 'society_hitman', 'society_hitman', 'society_hitman', {type = 'private'})

ESX.RegisterServerCallback('rHitman:getAllTarget', function(source, cb)
    local tableAllTarget = {}
    MySQL.Async.fetchAll("SELECT * FROM targethitman", {}, function(result)
        for k,v in pairs(result) do
            table.insert(tableAllTarget, {
                id = v.id,
                nameTarget = v.nametarget,
                ageTarget = v.agetarget,
                numTarget = v.numtarget,
            })
        end
        cb(tableAllTarget)
    end)
end)

RegisterServerEvent('rHitman:addTarget')
AddEventHandler('rHitman:addTarget', function(nameOfTarget, ageOfTarget, numberPhoneOfTarget)
    local _src = source
    local _nameOfTarget = nameOfTarget
    local _ageOfTarget = ageOfTarget
    local _numberPhoneOfTarget =  numberPhoneOfTarget

    MySQL.Async.execute('INSERT INTO targethitman (nametarget, agetarget, numtarget) VALUES (@nametarget, @agetarget, @numtarget)', {
        ['@nametarget']   = _nameOfTarget,
        ['@agetarget']   = _ageOfTarget,
        ['@numtarget'] = _numberPhoneOfTarget
    }, function()
        TriggerClientEvent('esx:showNotification', _src, "~r~Cible~s~ ajouter avec succès")
        TriggerClientEvent("rHitman:clientGetAllTarget", _src)
    end)
end)

RegisterServerEvent('rHitman:removeTarget')
AddEventHandler('rHitman:removeTarget', function(idTarget)
    local _src = source
    local _idTarget = idTarget

    MySQL.Async.execute('DELETE FROM targethitman WHERE id = @id', {
        ["@id"] = _idTarget
    }, function()
        TriggerClientEvent('esx:showNotification', _src, "~r~Cible~s~ supprimer avec succès")
        TriggerClientEvent("rHitman:clientGetAllTarget", _src)
    end)
end)

RegisterServerEvent('rHitman:sendMsgHitmans')
AddEventHandler('rHitman:sendMsgHitmans', function(msg)
    local xPlayers = ESX.GetPlayers()
    for i = 1, #xPlayers, 1 do
        local thePlayer = ESX.GetPlayerFromId(xPlayers[i])
        if thePlayer.job2.name == 'hitman' then
			TriggerClientEvent('esx:showAdvancedNotification', xPlayers[i], 'Information', '~y~Message de l\'équipe', msg, 'CHAR_MP_FM_CONTACT', 8)
        end
    end
end)

RegisterServerEvent('rHitman:addWeapon')
AddEventHandler('rHitman:addWeapon', function(weaponName, weaponLabel)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if not Config.WeaponItems then
		xPlayer.addWeapon(weaponName, Config.ammoAdd)
		TriggerClientEvent('esx:showNotification', _src, "~g~Vous avez recu votre:~s~ ~r~"..weaponLabel)
	else
		xPlayer.addInventoryItem(weaponName, 1)
		TriggerClientEvent('esx:showNotification', _src, "~g~Vous avez recu votre:~s~ ~r~"..weaponLabel)
	end
end)

RegisterServerEvent('rHitman:removeAllWeapons')
AddEventHandler('rHitman:removeAllWeapons', function()
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	if Config.WeaponItems then
		for k,v in pairs(Config.weaponInArmory) do
			for _,item in ipairs(xPlayer.getInventory()) do
				if string.upper(item.name) == string.upper(v.weapon) then
					xPlayer.removeInventoryItem(v.weapon, 1)
				end
			end
		end
	else
		for k,v in pairs(Config.weaponInArmory) do
			for _,weapon in ipairs(xPlayer.getLoadout()) do
				if string.upper(weapon.name) == string.upper(v.weapon) then
					xPlayer.removeWeapon(Config.weaponNameGood(v.weapon))
				end
			end
		end
	end
	TriggerClientEvent('esx:showNotification', _src, "Vous avez posé tous vos armes")
end)


ESX.RegisterServerCallback('rHitman:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_hitman', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterNetEvent('rHitman:getStockItem')
AddEventHandler('rHitman:getStockItem', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_hitman', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		if count > 0 and inventoryItem.count >= count then

			-- can the player carry the said amount of x item?
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)

ESX.RegisterServerCallback('rHitman:getPlayerInventory', function(source, cb)
    local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local items   = xPlayer.inventory

	cb({items = items})
end)

RegisterNetEvent('rHitman:putStockItems')
AddEventHandler('rHitman:putStockItems', function(itemName, count)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_hitman', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count >= count and count > 0 then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..inventoryItem.label.." x"..count, 'CHAR_MP_FM_CONTACT', 8)
		else
			TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', "Quantité ~r~invalide", 'CHAR_MP_FM_CONTACT', 9)
		end
	end)
end)


ESX.RegisterServerCallback('rHitman:getArmoryWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_hitman', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('rHitman:removeArmoryWeapon', function(source, cb, weaponName)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 500)
	TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez retiré ~r~'..ESX.GetWeaponLabel(weaponName).." x1", 'CHAR_MP_FM_CONTACT', 8)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_hitman', function(store)
		local weapons = store.get('weapons') or {}

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('rHitman:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end
	TriggerClientEvent('esx:showAdvancedNotification', _src, 'Coffre', '~o~Informations~s~', 'Vous avez déposé ~g~'..ESX.GetWeaponLabel(weaponName).." x1", 'CHAR_MP_FM_CONTACT', 8)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_hitman', function(store)
		local weapons = store.get('weapons') or {}
		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)