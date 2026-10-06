-- T8Defences
-- Tier 8 Super Defenses (Sub-Space Array, Supernova Battery, Shield Nullifier)
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

    -- Armada T8: Sub-Space Array - Heavy disintegration beam with PD & AA
    if unitDefs['armannit4'] then
        cloneUnit('armannit4', 'armannit8', {
            name = 'T8 Sub-Space Array',
            description = 'T8 Sub-Space Array - Heavy disintegration beam, PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['armannit4'].metalcost, 22.0),
            energycost = scaled(unitDefs['armannit4'].energycost, 22.0),
            buildtime = scaled(unitDefs['armannit4'].buildtime, 22.0),
            health = scaled(unitDefs['armannit4'].health, 16.0),
            footprintx = 9,
            footprintz = 9,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T8 Sub-Space Array',
                i18n_en_tooltip = 'Sub-space disintegration array with point defense and anti-air',
                techlevel = 8,
            },
            weapondefs = {
                ARMANNI_W1_T8 = {
                    name = 'T8 Sub-Space Disintegration Beam',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    beamtime = 1.5,
                    thickness = 12,
                    corethickness = 0.5,
                    laserflaresize = 14,
                    scrollspeed = 5,
                    texture3 = 'largebeam',
                    tilelength = 150,
                    range = 1950,
                    reloadtime = 3.5,
                    energypershot = 350000,
                    damage = { default = 75000, commanders = 15000 },
                    areaofeffect = 200,
                    rgbcolor = '0.1 0.7 1.0',
                    rgbcolor2 = '0.8 0.9 1.0',
                    soundhit = 'xplolrg3',
                    soundstart = 'annihilator1',
                    turret = true,
                    weaponvelocity = 2500,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W2_T8 = {
                    name = 'T8 Sub-Space Heavy PD',
                    weapontype = 'BeamLaser',
                    largebeamlaser = true,
                    range = 900,
                    reloadtime = 0.4,
                    beamtime = 0.3,
                    thickness = 6,
                    corethickness = 0.35,
                    energypershot = 12000,
                    damage = { default = 3800 },
                    areaofeffect = 64,
                    rgbcolor = '0.2 0.8 1.0',
                    soundhit = 'xplomed2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W3_T8 = {
                    name = 'T8 Disintegration AA Cannon',
                    weapontype = 'LaserCannon',
                    range = 1400,
                    reloadtime = 1.0,
                    energypershot = 15000,
                    burst = 4,
                    burstrate = 0.15,
                    damage = { default = 2200, vtol = 6000 },
                    areaofeffect = 48,
                    rgbcolor = '0.1 0.7 1.0',
                    soundhit = 'xplomed1',
                    soundstart = 'annigun1',
                    turret = true,
                    weaponvelocity = 3000,
                    thickness = 8,
                    laserflaresize = 9,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'ARMANNI_W1_T8', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'ARMANNI_W2_T8', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'ARMANNI_W3_T8', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Cortex T8: Supernova Battery - Heavy plasma shells with PD & flak AA
    if unitDefs['cordoomt4'] then
        cloneUnit('cordoomt4', 'cordoomt8', {
            name = 'T8 Supernova Battery',
            description = 'T8 Supernova Battery - Heavy plasma shells, PD & flak AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['cordoomt4'].metalcost, 22.0),
            energycost = scaled(unitDefs['cordoomt4'].energycost, 22.0),
            buildtime = scaled(unitDefs['cordoomt4'].buildtime, 22.0),
            health = scaled(unitDefs['cordoomt4'].health, 16.0),
            footprintx = 10,
            footprintz = 10,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T8 Supernova Battery',
                i18n_en_tooltip = 'Heavy plasma shell battery with thermal point defense and flak anti-air',
                techlevel = 8,
            },
            weapondefs = {
                CORDOOM_W1_T8 = {
                    name = 'T8 Supernova Plasma Shell',
                    weapontype = 'Cannon',
                    range = 1950,
                    reloadtime = 3.5,
                    energypershot = 350000,
                    projectiles = 6,
                    sprayangle = 1000,
                    cratermult = 3.0,
                    damage = { default = 80000 },
                    areaofeffect = 500,
                    soundhit = 'xplolrg3',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W2_T8 = {
                    name = 'T8 Supernova Thermal PD',
                    weapontype = 'Cannon',
                    range = 800,
                    reloadtime = 0.5,
                    energypershot = 10000,
                    firestarter = 100,
                    damage = { default = 3000 },
                    areaofeffect = 96,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 1500,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W3_T8 = {
                    name = 'T8 Plasma Flak AA Battery',
                    weapontype = 'Cannon',
                    range = 1300,
                    reloadtime = 0.6,
                    energypershot = 12000,
                    damage = { default = 1500, vtol = 5000 },
                    areaofeffect = 120,
                    soundhit = 'xplolrg1',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 2400,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'CORDOOM_W1_T8', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'CORDOOM_W2_T8', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'CORDOOM_W3_T8', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Legion T8: Shield Nullifier - Heavy EMP railgun with grid PD & AA
    if unitDefs['legbastiont4'] then
        cloneUnit('legbastiont4', 'legbastiont8', {
            name = 'T8 Shield Nullifier',
            description = 'T8 Shield Nullifier - Heavy EMP railgun, grid PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['legbastiont4'].metalcost, 22.0),
            energycost = scaled(unitDefs['legbastiont4'].energycost, 22.0),
            buildtime = scaled(unitDefs['legbastiont4'].buildtime, 22.0),
            health = scaled(unitDefs['legbastiont4'].health, 16.0),
            footprintx = 9,
            footprintz = 9,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T8 Shield Nullifier',
                i18n_en_tooltip = 'Heavy EMP railgun with grid collapse point defense and anti-air',
                techlevel = 8,
            },
            weapondefs = {
                LEGBASTION_W1_T8 = {
                    name = 'T8 Shield Nullifier Railgun',
                    weapontype = 'Cannon',
                    paralyzer = true,
                    paralyzetime = 20,
                    range = 1950,
                    reloadtime = 3.5,
                    energypershot = 330000,
                    impulsefactor = -3.0,
                    damage = { default = 75000, commanders = 15000 },
                    areaofeffect = 600,
                    soundhit = 'xplomed2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W2_T8 = {
                    name = 'T8 Grid Collapse PD Beam',
                    weapontype = 'BeamLaser',
                    paralyzer = true,
                    paralyzetime = 12,
                    range = 900,
                    reloadtime = 0.4,
                    beamtime = 0.2,
                    thickness = 5,
                    energypershot = 10000,
                    damage = { default = 3200 },
                    areaofeffect = 64,
                    soundhit = 'sizzle',
                    soundstart = 'banthie2',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W3_T8 = {
                    name = 'T8 Nullifier AA Burst Railgun',
                    weapontype = 'Cannon',
                    range = 1350,
                    reloadtime = 0.8,
                    energypershot = 14000,
                    burst = 3,
                    burstrate = 0.15,
                    damage = { default = 1800, vtol = 5500 },
                    areaofeffect = 64,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 2400,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'LEGBASTION_W1_T8', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'LEGBASTION_W2_T8', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'LEGBASTION_W3_T8', onlytargetcategory = 'VTOL' },
            },
        })
    end

    local newUnitNames = { 'armannit8', 'cordoomt8', 'legbastiont8' }

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
