-- T5Defences
-- Tier 5 Super Defenses (Pulsar Array, Hellstorm Battery, Void Emitter)
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

    -- Armada T5: Pulsar Array - Rapid tachyon beams with PD & AA
    if unitDefs['armannit4'] then
        cloneUnit('armannit4', 'armannit5', {
            name = 'T5 Pulsar Array',
            description = 'T5 Pulsar Array - Rapid tachyon beams, PD & AA (large explosion)',
            metalcost = scaled(unitDefs['armannit4'].metalcost, 2.5),
            energycost = scaled(unitDefs['armannit4'].energycost, 2.5),
            buildtime = scaled(unitDefs['armannit4'].buildtime, 2.5),
            health = scaled(unitDefs['armannit4'].health, 2.0),
            footprintx = 6,
            footprintz = 6,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T5 Pulsar Array',
                i18n_en_tooltip = 'Rapid-fire tachyon beam array with point defense and anti-air',
                techlevel = 5,
            },
            weapondefs = {
                ARMANNI_W1_T5 = {
                    name = 'T5 Tachyon Beam Array',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    beamtime = 1.0,
                    thickness = 8,
                    corethickness = 0.4,
                    laserflaresize = 10,
                    scrollspeed = 5,
                    texture3 = 'largebeam',
                    tilelength = 150,
                    range = 1400,
                    reloadtime = 2.0,
                    energypershot = 35000,
                    damage = { default = 10000 },
                    areaofeffect = 100,
                    rgbcolor = '0.8 0.2 1.0',
                    rgbcolor2 = '0.9 0.5 1.0',
                    soundhit = 'xplolrg2',
                    soundstart = 'annihilator1',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W2_T5 = {
                    name = 'T5 Pulsar Point Defense',
                    weapontype = 'BeamLaser',
                    range = 650,
                    reloadtime = 0.4,
                    beamtime = 0.2,
                    thickness = 4,
                    energypershot = 2500,
                    impactonly = 1,
                    damage = { default = 800 },
                    areaofeffect = 32,
                    rgbcolor = '0.3 0.7 1.0',
                    soundhit = 'sizzle',
                    soundstart = 'beamershot2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W3_T5 = {
                    name = 'T5 Pulsar AA Laser',
                    weapontype = 'LaserCannon',
                    range = 1000,
                    reloadtime = 1.0,
                    energypershot = 3000,
                    burst = 3,
                    burstrate = 0.15,
                    damage = { default = 600, vtol = 1800 },
                    areaofeffect = 28,
                    rgbcolor = '0.4 0.6 1.0',
                    soundhit = 'xplomed1',
                    soundstart = 'annigun1',
                    turret = true,
                    weaponvelocity = 2500,
                    thickness = 5,
                    laserflaresize = 6,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'ARMANNI_W1_T5', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'ARMANNI_W2_T5', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'ARMANNI_W3_T5', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Cortex T5: Hellstorm Battery - Cluster shells with flame PD & flak AA
    if unitDefs['cordoomt4'] then
        cloneUnit('cordoomt4', 'cordoomt5', {
            name = 'T5 Hellstorm Battery',
            description = 'T5 Hellstorm Battery - Cluster shells, flame PD & flak AA (large explosion)',
            metalcost = scaled(unitDefs['cordoomt4'].metalcost, 2.5),
            energycost = scaled(unitDefs['cordoomt4'].energycost, 2.5),
            buildtime = scaled(unitDefs['cordoomt4'].buildtime, 2.5),
            health = scaled(unitDefs['cordoomt4'].health, 2.0),
            footprintx = 7,
            footprintz = 7,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T5 Hellstorm Battery',
                i18n_en_tooltip = 'Cluster shell battery with flame point defense and flak anti-air',
                techlevel = 5,
            },
            weapondefs = {
                CORDOOM_W1_T5 = {
                    name = 'T5 Hellstorm Cluster Cannon',
                    weapontype = 'Cannon',
                    range = 1300,
                    reloadtime = 2.5,
                    energypershot = 40000,
                    projectiles = 4,
                    sprayangle = 600,
                    damage = { default = 12000 },
                    areaofeffect = 180,
                    cratermult = 2.0,
                    soundhit = 'xplolrg2',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 1600,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W2_T5 = {
                    name = 'T5 Inferno Point Defense',
                    weapontype = 'Cannon',
                    range = 600,
                    reloadtime = 0.5,
                    energypershot = 3000,
                    firestarter = 80,
                    damage = { default = 800 },
                    areaofeffect = 64,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 1200,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W3_T5 = {
                    name = 'T5 Hellstorm Flak AA',
                    weapontype = 'Cannon',
                    range = 900,
                    reloadtime = 0.8,
                    energypershot = 3500,
                    damage = { default = 600, vtol = 2000 },
                    areaofeffect = 80,
                    soundhit = 'xplolrg1',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'CORDOOM_W1_T5', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'CORDOOM_W2_T5', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'CORDOOM_W3_T5', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Legion T5: Void Emitter - Gravity cannon with stasis PD & AA
    if unitDefs['legbastiont4'] then
        cloneUnit('legbastiont4', 'legbastiont5', {
            name = 'T5 Void Emitter',
            description = 'T5 Void Emitter - Gravity cannon, stasis PD & AA (large explosion)',
            metalcost = scaled(unitDefs['legbastiont4'].metalcost, 2.5),
            energycost = scaled(unitDefs['legbastiont4'].energycost, 2.5),
            buildtime = scaled(unitDefs['legbastiont4'].buildtime, 2.5),
            health = scaled(unitDefs['legbastiont4'].health, 2.0),
            footprintx = 6,
            footprintz = 6,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T5 Void Emitter',
                i18n_en_tooltip = 'Gravity well cannon with stasis point defense and anti-air',
                techlevel = 5,
            },
            weapondefs = {
                LEGBASTION_W1_T5 = {
                    name = 'T5 Gravity Well Cannon',
                    weapontype = 'Cannon',
                    range = 1350,
                    reloadtime = 2.5,
                    energypershot = 38000,
                    impulsefactor = 2.0,
                    damage = { default = 11000 },
                    areaofeffect = 160,
                    soundhit = 'xplolrg2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 1500,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W2_T5 = {
                    name = 'T5 Stasis Point Defense',
                    weapontype = 'BeamLaser',
                    paralyzer = true,
                    paralyzetime = 5,
                    range = 550,
                    reloadtime = 0.4,
                    beamtime = 0.2,
                    thickness = 4,
                    energypershot = 2000,
                    damage = { default = 500 },
                    soundhit = 'sizzle',
                    soundstart = 'banthie2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W3_T5 = {
                    name = 'T5 Void AA Burst',
                    weapontype = 'Cannon',
                    range = 850,
                    reloadtime = 0.9,
                    energypershot = 2800,
                    burst = 2,
                    burstrate = 0.2,
                    damage = { default = 500, vtol = 1600 },
                    areaofeffect = 36,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'LEGBASTION_W1_T5', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'LEGBASTION_W2_T5', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'LEGBASTION_W3_T5', onlytargetcategory = 'VTOL' },
            },
        })
    end

    local newUnitNames = { 'armannit5', 'cordoomt5', 'legbastiont5' }

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
