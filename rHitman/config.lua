Config = {
    newESX = false, -- Vous utilisez la nouvelle ou l'ancien version ESX ?
    WeaponItems = false, -- Vous utilisez les armes en items ?
    userMenuBoss = false, -- Vous utilisez le script rMenuBoss (By Rayan) ?
    allowWhiten = false, -- Si, vous utilisez le rMenuBoss, est ce que vous voulez autorise le blanchiment d'argent ? 
    posCoffre = vector3(3850.212890625, 3639.4174804688, 15.690184593201),
    posArmory = vector3(3845.3723144531, 3638.6320800781, 15.690179824829),
    posVestaire = vector3(3855.7106933594, 3633.7346191406, 15.690192222595),
    posMenuBoss = vector3(3849.84, 3637.92, 15.69),
    posMenuCar = vector3(3807.7915039063, 4478.6469726563, 6.3653960227966),
    posSpawnCar = vector4(3809.7858886719, 4472.6103515625, 4.0098900794983, 111.26371002197),
    posMenuHelico = vector3(3845.02, 3664.99, 5.69),
    posSpawnHelico = vector4(3838.92, 3664.41, 5.69, 1.4872233867645),
    posBoat = {
        menuPos = {
            vector3(3853.12, 3660.55, 3.14),
            vector3(3854.7756347656, 4458.46484375, 1.8497657775879)
        },
        spawnPos = {
            vector4(3856.95, 3660.99, 1.12, 357.502),
            vector4(3854.7524414063, 4453.3544921875, 0.72612774372101, 268.72741699219)
        }
    },
    posTpDown = vector3(3850.322265625, 3636.4592285156, 5.204110622406),
    posTpUp = vector3(3856.8745117188, 3617.6721191406, 23.431816101074),

    carInGarage = {
        {label = "Sultan RS", model = "sultanrs"}
    },
    boatInGarage = {
        {label = "Dinghy 4", model = "dinghy4"}
    },
    helicoInGarage = {
        {label = "Maverick", model = "maverick"}
    },
    weaponInArmory = {
        {label = "Sniper", weapon = "weapon_sniperrifle"},
        {label = "Pistolet", weapon = "weapon_pistol"},
    },
    ammoAdd = 200, -- Combien de munitions donner ?
    weaponNameGood = function(weaponName) -- Pas besoin de touche !
        return string.upper(weaponName)
    end,

    uniform = {
        maleWear = {
            tshirt_1 = 31,  tshirt_2 = 0,
            torso_1 = 32,   torso_2 = 0,
            arms = 27,
            pants_1 = 24,   pants_2 = 0,
            shoes_1 = 10,   shoes_2 = 0,
        },

        femaleWear = {
            tshirt_1 = 31,  tshirt_2 = 0,
            torso_1 = 32,   torso_2 = 0,
            arms = 27,
            pants_1 = 24,   pants_2 = 0,
            shoes_1 = 10,   shoes_2 = 0,
        },
    },
}