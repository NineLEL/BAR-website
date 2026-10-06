-- T6Defences
-- Tier 6 Super Defenses (Nova Cannon, Magma Battery, Rift Emitter)
-- https://github.com/nuttyb-community/nuttyb

do
    local unitDefs, tableMerge = UnitDefs or {}, table.merge

    local function ensureBuildOption(builderName, optionName)
        local builder = unitDefs[builderName]
        local optionDef = optionName and unitDefs[optionName]
        if not builder or not optionDef then
            return
        end

        builder.buildoptions = builder.buildoptions or {}
        for i = 1, #builder.buildoptions do
            if builder.buildoptions[i] == optionName then
                return
            end
        end

        builder.buildoptions[#builder.buildoptions + 1] = optionName
    end

    local function scaled(value, multiplier)
        return value and math.ceil(value * multiplier) or nil
    end

    local function cloneUnit(sourceUnit, targetUnit, overrides)
        if unitDefs[sourceUnit] and not unitDefs[targetUnit] then
            unitDefs[targetUnit] = tableMerge(unitDefs[sourceUnit], overrides)
        end
    end

    -- Armada T6: Nova Cannon - Heavy disintegration beam with PD & AA
    if unitDefs['armannit4'] then
        cloneUnit('armannit4', 'armannit6', {
            name = 'T6 Nova Cannon',
            description = 'T6 Nova Cannon - Heavy disintegration beam, PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['armannit4'].metalcost, 5.0),
            energycost = scaled(unitDefs['armannit4'].energycost, 5.0),
            buildtime = scaled(unitDefs['armannit4'].buildtime, 5.0),
            health = scaled(unitDefs['armannit4'].health, 4.0),
            footprintx = 7,
            footprintz = 7,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T6 Nova Cannon',
                i18n_en_tooltip = 'Heavy disintegration beam array with point defense and anti-air',
                techlevel = 6,
            },
            weapondefs = {
                ARMANNI_W1_T6 = {
                    name = 'T6 Nova Disintegration Beam',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    beamtime = 1.2,
                    thickness = 10,
                    corethickness = 0.5,
                    laserflaresize = 12,
                    scrollspeed = 5,
                    texture3 = 'largebeam',
                    tilelength = 150,
                    range = 1600,
                    reloadtime = 2.5,
                    energypershot = 75000,
                    damage = { default = 22000 },
                    areaofeffect = 140,
                    rgbcolor = '0.6 0.1 1.0',
                    rgbcolor2 = '0.9 0.4 1.0',
                    soundhit = 'xplolrg3',
                    soundstart = 'annihilator1',
                    turret = true,
                    weaponvelocity = 2200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W2_T6 = {
                    name = 'T6 Nova Heavy PD',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    range = 750,
                    reloadtime = 0.4,
                    beamtime = 0.3,
                    thickness = 5,
                    corethickness = 0.3,
                    energypershot = 5000,
                    damage = { default = 1400 },
                    areaofeffect = 48,
                    rgbcolor = '0.5 0.2 1.0',
                    soundhit = 'xplomed2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W3_T6 = {
                    name = 'T6 Nova AA Burst Laser',
                    weapontype = 'LaserCannon',
                    range = 1100,
                    reloadtime = 1.0,
                    energypershot = 4500,
                    burst = 3,
                    burstrate = 0.15,
                    damage = { default = 900, vtol = 2800 },
                    areaofeffect = 36,
                    rgbcolor = '0.2 0.5 1.0',
                    soundhit = 'xplomed1',
                    soundstart = 'annigun1',
                    turret = true,
                    weaponvelocity = 2600,
                    thickness = 6,
                    laserflaresize = 7,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'ARMANNI_W1_T6', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'ARMANNI_W2_T6', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'ARMANNI_W3_T6', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Cortex T6: Magma Battery - Heavy plasma shells with thermal PD & flak AA
    if unitDefs['cordoomt4'] then
        cloneUnit('cordoomt4', 'cordoomt6', {
            name = 'T6 Magma Battery',
            description = 'T6 Magma Battery - Heavy plasma shells, thermal PD & flak AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['cordoomt4'].metalcost, 5.0),
            energycost = scaled(unitDefs['cordoomt4'].energycost, 5.0),
            buildtime = scaled(unitDefs['cordoomt4'].buildtime, 5.0),
            health = scaled(unitDefs['cordoomt4'].health, 4.0),
            footprintx = 8,
            footprintz = 8,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T6 Magma Battery',
                i18n_en_tooltip = 'Heavy plasma shell battery with thermal point defense and flak anti-air',
                techlevel = 6,
            },
            weapondefs = {
                CORDOOM_W1_T6 = {
                    name = 'T6 Magma Plasma Shell',
                    weapontype = 'Cannon',
                    range = 1550,
                    reloadtime = 2.8,
                    energypershot = 80000,
                    projectiles = 5,
                    sprayangle = 800,
                    damage = { default = 25000 },
                    areaofeffect = 240,
                    cratermult = 2.5,
                    soundhit = 'xplolrg3',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 1700,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W2_T6 = {
                    name = 'T6 Thermal Point Defense',
                    weapontype = 'Cannon',
                    range = 700,
                    reloadtime = 0.5,
                    energypershot = 5500,
                    firestarter = 100,
                    damage = { default = 1600 },
                    areaofeffect = 80,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 1400,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W3_T6 = {
                    name = 'T6 Magma Flak AA',
                    weapontype = 'Cannon',
                    range = 1050,
                    reloadtime = 0.7,
                    energypershot = 5000,
                    damage = { default = 1000, vtol = 3500 },
                    areaofeffect = 100,
                    soundhit = 'xplolrg1',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 2200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'CORDOOM_W1_T6', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'CORDOOM_W2_T6', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'CORDOOM_W3_T6', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Legion T6: Rift Emitter - EMP railgun with paralyzer PD & AA
    if unitDefs['legbastiont4'] then
        cloneUnit('legbastiont4', 'legbastiont6', {
            name = 'T6 Rift Emitter',
            description = 'T6 Rift Emitter - EMP railgun, paralyzer PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['legbastiont4'].metalcost, 5.0),
            energycost = scaled(unitDefs['legbastiont4'].energycost, 5.0),
            buildtime = scaled(unitDefs['legbastiont4'].buildtime, 5.0),
            health = scaled(unitDefs['legbastiont4'].health, 4.0),
            footprintx = 7,
            footprintz = 7,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T6 Rift Emitter',
                i18n_en_tooltip = 'EMP railgun emitter with paralyzer point defense and anti-air',
                techlevel = 6,
            },
            weapondefs = {
                LEGBASTION_W1_T6 = {
                    name = 'T6 Rift EMP Railgun',
                    weapontype = 'Cannon',
                    paralyzer = true,
                    paralyzetime = 10,
                    range = 1550,
                    reloadtime = 2.8,
                    energypershot = 72000,
                    impulsefactor = -2.5,
                    damage = { default = 22000 },
                    areaofeffect = 280,
                    soundhit = 'xplomed2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W2_T6 = {
                    name = 'T6 Rift Paralyzer PD',
                    weapontype = 'BeamLaser',
                    paralyzer = true,
                    paralyzetime = 7,
                    range = 650,
                    reloadtime = 0.4,
                    beamtime = 0.2,
                    thickness = 4,
                    energypershot = 4000,
                    damage = { default = 1100 },
                    soundhit = 'sizzle',
                    soundstart = 'banthie2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W3_T6 = {
                    name = 'T6 Rift AA Burst',
                    weapontype = 'Cannon',
                    range = 1000,
                    reloadtime = 0.8,
                    energypershot = 4500,
                    burst = 3,
                    burstrate = 0.15,
                    damage = { default = 800, vtol = 3000 },
                    areaofeffect = 48,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 2200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'LEGBASTION_W1_T6', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'LEGBASTION_W2_T6', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'LEGBASTION_W3_T6', onlytargetcategory = 'VTOL' },
            },
        })
    end

    local newUnitNames = { 'armannit6', 'cordoomt6', 'legbastiont6' }

    local builders = {
        'armack', 'armaca', 'armacv', 'armt3airaide', 'armt3aide',
        'corack', 'coraca', 'coracv', 'cort3airaide', 'cort3aide',
        'legack', 'legaca', 'legacv', 'legt3airaide', 'legt3aide',
    }

    for _, builderName in pairs(builders) do
        local faction = builderName:sub(1, 3)

        for _, newUnitName in ipairs(newUnitNames) do
            if (newUnitName:sub(1, 3)) == faction then
                ensureBuildOption(builderName, newUnitName)
            end
        end
    end
end
