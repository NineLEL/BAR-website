-- T9Defences
-- Tier 9 Super Defenses (Celestial Nova Array, Apocalypse Hellfire Battery, Cosmic Event Horizon Emitter)
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

    -- Armada T9: Celestial Nova Array - Orbital Tachyon Death-Ray, PD & AA
    if unitDefs['armannit4'] then
        cloneUnit('armannit4', 'armannit9', {
            name = 'T9 Celestial Nova Array',
            description = 'T9 Celestial Nova Array - Orbital Tachyon Death-Ray, PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['armannit4'].metalcost, 50.0),
            energycost = scaled(unitDefs['armannit4'].energycost, 50.0),
            buildtime = scaled(unitDefs['armannit4'].buildtime, 50.0),
            health = scaled(unitDefs['armannit4'].health, 35.0),
            footprintx = 10,
            footprintz = 10,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T9 Celestial Nova Array',
                i18n_en_tooltip = 'Celestial tachyon death-ray with point defense and anti-air array',
                techlevel = 9,
            },
            weapondefs = {
                ARMANNI_W1_T9 = {
                    name = 'T9 Celestial Tachyon Death-Ray',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    beamtime = 2.5,
                    thickness = 16,
                    corethickness = 0.6,
                    laserflaresize = 16,
                    scrollspeed = 6,
                    texture3 = 'largebeam',
                    tilelength = 150,
                    range = 2200,
                    reloadtime = 4.0,
                    energypershot = 800000,
                    damage = { default = 120000 },
                    areaofeffect = 400,
                    cratermult = 3.0,
                    rgbcolor = '1.0 0.2 0.8',
                    rgbcolor2 = '1.0 0.8 0.9',
                    soundhit = 'xplolrg3',
                    soundstart = 'annihilator1',
                    turret = true,
                    weaponvelocity = 3000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W2_T9 = {
                    name = 'T9 Celestial Heavy PD',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    range = 1000,
                    reloadtime = 0.3,
                    beamtime = 0.2,
                    thickness = 8,
                    corethickness = 0.4,
                    energypershot = 20000,
                    damage = { default = 7000 },
                    areaofeffect = 80,
                    rgbcolor = '0.8 0.2 1.0',
                    soundhit = 'xplomed2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 2200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W3_T9 = {
                    name = 'T9 Celestial AA Array',
                    weapontype = 'LaserCannon',
                    range = 1600,
                    reloadtime = 0.8,
                    energypershot = 25000,
                    burst = 5,
                    burstrate = 0.1,
                    damage = { default = 3500, vtol = 10000 },
                    areaofeffect = 64,
                    rgbcolor = '0.1 0.5 1.0',
                    soundhit = 'xplomed1',
                    soundstart = 'annigun1',
                    turret = true,
                    weaponvelocity = 3200,
                    thickness = 10,
                    laserflaresize = 12,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'ARMANNI_W1_T9', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'ARMANNI_W2_T9', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'ARMANNI_W3_T9', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Cortex T9: Apocalypse Hellfire Battery - Nuclear Shell Cannon, PD & Flak AA
    if unitDefs['cordoomt4'] then
        cloneUnit('cordoomt4', 'cordoomt9', {
            name = 'T9 Apocalypse Hellfire Battery',
            description = 'T9 Apocalypse Hellfire Battery - Nuclear shell cannon, PD & flak AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['cordoomt4'].metalcost, 50.0),
            energycost = scaled(unitDefs['cordoomt4'].energycost, 50.0),
            buildtime = scaled(unitDefs['cordoomt4'].buildtime, 50.0),
            health = scaled(unitDefs['cordoomt4'].health, 35.0),
            footprintx = 12,
            footprintz = 12,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T9 Apocalypse Hellfire Battery',
                i18n_en_tooltip = 'Nuclear shell cannon battery with thermal point defense and flak anti-air',
                techlevel = 9,
            },
            weapondefs = {
                CORDOOM_W1_T9 = {
                    name = 'T9 Nuclear Hellfire Shell',
                    weapontype = 'Cannon',
                    range = 2200,
                    reloadtime = 4.0,
                    energypershot = 800000,
                    damage = { default = 130000 },
                    areaofeffect = 700,
                    cratermult = 4.0,
                    explosiongenerator = 'custom:genericshellexplosion-huge-bomb',
                    soundhit = 'xplolrg3',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 2200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W2_T9 = {
                    name = 'T9 Apocalypse Thermal PD',
                    weapontype = 'Cannon',
                    range = 900,
                    reloadtime = 0.4,
                    energypershot = 18000,
                    firestarter = 100,
                    damage = { default = 5000 },
                    areaofeffect = 120,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W3_T9 = {
                    name = 'T9 Hellfire Flak AA',
                    weapontype = 'Cannon',
                    range = 1500,
                    reloadtime = 0.5,
                    energypershot = 22000,
                    damage = { default = 3000, vtol = 9000 },
                    areaofeffect = 150,
                    soundhit = 'xplolrg1',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 2600,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'CORDOOM_W1_T9', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'CORDOOM_W2_T9', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'CORDOOM_W3_T9', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Legion T9: Cosmic Event Horizon Emitter - Antimatter Beam, Paralyzer PD & AA
    if unitDefs['legbastiont4'] then
        cloneUnit('legbastiont4', 'legbastiont9', {
            name = 'T9 Cosmic Event Horizon Emitter',
            description = 'T9 Cosmic Event Horizon Emitter - Antimatter beam, paralyzer PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['legbastiont4'].metalcost, 50.0),
            energycost = scaled(unitDefs['legbastiont4'].energycost, 50.0),
            buildtime = scaled(unitDefs['legbastiont4'].buildtime, 50.0),
            health = scaled(unitDefs['legbastiont4'].health, 35.0),
            footprintx = 10,
            footprintz = 10,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T9 Cosmic Event Horizon Emitter',
                i18n_en_tooltip = 'Event horizon antimatter beam with paralyzer point defense and anti-air',
                techlevel = 9,
            },
            weapondefs = {
                LEGBASTION_W1_T9 = {
                    name = 'T9 Event Horizon Disintegrator',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    beamtime = 2.0,
                    thickness = 14,
                    corethickness = 0.5,
                    laserflaresize = 15,
                    scrollspeed = 5,
                    texture3 = 'largebeam',
                    tilelength = 150,
                    range = 2200,
                    reloadtime = 4.0,
                    energypershot = 800000,
                    damage = { default = 125000 },
                    areaofeffect = 500,
                    rgbcolor = '0.9 0.1 0.2',
                    rgbcolor2 = '1.0 0.6 0.2',
                    soundhit = 'xplolrg3',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 2500,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W2_T9 = {
                    name = 'T9 Event Horizon Paralyzer PD',
                    weapontype = 'BeamLaser',
                    paralyzer = true,
                    paralyzetime = 15,
                    range = 950,
                    reloadtime = 0.3,
                    beamtime = 0.2,
                    thickness = 6,
                    energypershot = 16000,
                    damage = { default = 4500 },
                    areaofeffect = 80,
                    soundhit = 'sizzle',
                    soundstart = 'banthie2',
                    turret = true,
                    weaponvelocity = 2200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W3_T9 = {
                    name = 'T9 Cosmic AA Burst',
                    weapontype = 'Cannon',
                    range = 1500,
                    reloadtime = 0.7,
                    energypershot = 20000,
                    burst = 4,
                    burstrate = 0.1,
                    damage = { default = 2800, vtol = 8500 },
                    areaofeffect = 80,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 2600,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'LEGBASTION_W1_T9', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'LEGBASTION_W2_T9', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'LEGBASTION_W3_T9', onlytargetcategory = 'VTOL' },
            },
        })
    end

    local newUnitNames = { 'armannit9', 'cordoomt9', 'legbastiont9' }

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
