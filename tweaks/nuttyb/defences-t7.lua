-- T7Defences
-- Tier 7 Super Defenses (Seismic Disruptor, Bio-Mortar Array, Antimatter Cannon)
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

    -- Armada T7: Seismic Disruptor - Tectonic cratering wave with PD & AA
    if unitDefs['armannit4'] then
        cloneUnit('armannit4', 'armannit7', {
            name = 'T7 Seismic Disruptor',
            description = 'T7 Seismic Disruptor - Tectonic cratering wave, PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['armannit4'].metalcost, 10.0),
            energycost = scaled(unitDefs['armannit4'].energycost, 10.0),
            buildtime = scaled(unitDefs['armannit4'].buildtime, 10.0),
            health = scaled(unitDefs['armannit4'].health, 8.0),
            footprintx = 8,
            footprintz = 8,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T7 Seismic Disruptor',
                i18n_en_tooltip = 'Tectonic cratering wave cannon with point defense and anti-air',
                techlevel = 7,
            },
            weapondefs = {
                ARMANNI_W1_T7 = {
                    name = 'T7 Tectonic Shockwave Cannon',
                    weapontype = 'Cannon',
                    range = 1700,
                    reloadtime = 3.0,
                    energypershot = 150000,
                    cylindertargeting = 1,
                    cratermult = 3.0,
                    impulsefactor = 3.0,
                    damage = { default = 40000 },
                    areaofeffect = 300,
                    soundhit = 'xplolrg3',
                    soundstart = 'cannhvy1',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W2_T7 = {
                    name = 'T7 Shockwave Point Defense',
                    weapontype = 'Cannon',
                    range = 800,
                    reloadtime = 0.5,
                    energypershot = 8000,
                    cratermult = 1.5,
                    damage = { default = 2000 },
                    areaofeffect = 80,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 1500,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                ARMANNI_W3_T7 = {
                    name = 'T7 Tectonic AA Burst Laser',
                    weapontype = 'LaserCannon',
                    range = 1200,
                    reloadtime = 1.0,
                    energypershot = 6000,
                    burst = 3,
                    burstrate = 0.2,
                    damage = { default = 1200, vtol = 3800 },
                    areaofeffect = 32,
                    rgbcolor = '0.2 0.8 1.0',
                    soundhit = 'xplomed1',
                    soundstart = 'annigun1',
                    turret = true,
                    weaponvelocity = 2800,
                    thickness = 7,
                    laserflaresize = 8,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'ARMANNI_W1_T7', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'ARMANNI_W2_T7', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'ARMANNI_W3_T7', onlytargetcategory = 'VTOL' },
            },
        })
    end

    -- Cortex T7: Bio-Mortar Array - Armor melting MIRV with spray & PD
    if unitDefs['cordoomt4'] then
        cloneUnit('cordoomt4', 'cordoomt7', {
            name = 'T7 Bio-Mortar Array',
            description = 'T7 Bio-Mortar Array - Armor melting MIRV, spray & PD (catastrophic explosion)',
            metalcost = scaled(unitDefs['cordoomt4'].metalcost, 10.0),
            energycost = scaled(unitDefs['cordoomt4'].energycost, 10.0),
            buildtime = scaled(unitDefs['cordoomt4'].buildtime, 10.0),
            health = scaled(unitDefs['cordoomt4'].health, 8.0),
            footprintx = 9,
            footprintz = 9,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T7 Bio-Mortar Array',
                i18n_en_tooltip = 'Armor melting MIRV battery with corrosive spray and point defense',
                techlevel = 7,
            },
            weapondefs = {
                CORDOOM_W1_T7 = {
                    name = 'T7 Corrupting MIRV Battery',
                    weapontype = 'Cannon',
                    range = 1700,
                    reloadtime = 3.0,
                    energypershot = 150000,
                    projectiles = 5,
                    sprayangle = 1500,
                    damage = { default = 45000 },
                    areaofeffect = 400,
                    soundhit = 'xplomed2',
                    soundstart = 'cannhvy2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W2_T7 = {
                    name = 'T7 Corrosive Spray Ray',
                    weapontype = 'BeamLaser',
                    range = 900,
                    reloadtime = 0.4,
                    beamtime = 0.3,
                    thickness = 6,
                    energypershot = 10000,
                    firestarter = 100,
                    damage = { default = 2500 },
                    areaofeffect = 64,
                    rgbcolor = '0.1 0.9 0.2',
                    soundhit = 'sizzle',
                    soundstart = 'heatray2xl',
                    turret = true,
                    weaponvelocity = 2000,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                CORDOOM_W3_T7 = {
                    name = 'T7 Bio-PD Laser',
                    weapontype = 'BeamLaser',
                    range = 600,
                    reloadtime = 0.2,
                    beamtime = 0.1,
                    thickness = 4,
                    energypershot = 3000,
                    impactonly = 1,
                    damage = { default = 1000 },
                    soundhit = 'sizzle',
                    soundstart = 'beamershot2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
            },
            weapons = {
                [1] = { def = 'CORDOOM_W1_T7', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'CORDOOM_W2_T7', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'CORDOOM_W3_T7', onlytargetcategory = 'SURFACE' },
            },
        })
    end

    -- Legion T7: Antimatter Cannon - Airburst spheres with paralyzer PD & AA
    if unitDefs['legbastiont4'] then
        cloneUnit('legbastiont4', 'legbastiont7', {
            name = 'T7 Antimatter Cannon',
            description = 'T7 Antimatter Cannon - Airburst spheres, paralyzer PD & AA (catastrophic explosion)',
            metalcost = scaled(unitDefs['legbastiont4'].metalcost, 10.0),
            energycost = scaled(unitDefs['legbastiont4'].energycost, 10.0),
            buildtime = scaled(unitDefs['legbastiont4'].buildtime, 10.0),
            health = scaled(unitDefs['legbastiont4'].health, 8.0),
            footprintx = 8,
            footprintz = 8,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T7 Antimatter Cannon',
                i18n_en_tooltip = 'Antimatter airburst spheres with paralyzer PD and anti-air',
                techlevel = 7,
            },
            weapondefs = {
                LEGBASTION_W1_T7 = {
                    name = 'T7 Antimatter Split Sphere',
                    weapontype = 'Cannon',
                    range = 1700,
                    reloadtime = 3.0,
                    energypershot = 140000,
                    impulsefactor = 2.5,
                    damage = { default = 42000 },
                    areaofeffect = 300,
                    soundhit = 'xplolrg2',
                    soundstart = 'laser2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W2_T7 = {
                    name = 'T7 Antimatter Paralyzer Laser',
                    weapontype = 'BeamLaser',
                    paralyzer = true,
                    paralyzetime = 10,
                    range = 750,
                    reloadtime = 0.4,
                    beamtime = 0.2,
                    thickness = 5,
                    energypershot = 5000,
                    damage = { default = 1800 },
                    soundhit = 'sizzle',
                    soundstart = 'banthie2',
                    turret = true,
                    weaponvelocity = 1800,
                    allowNonBlockingAim = true,
                    collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
                },
                LEGBASTION_W3_T7 = {
                    name = 'T7 Split Cluster AA Battery',
                    weapontype = 'Cannon',
                    range = 1100,
                    reloadtime = 0.8,
                    energypershot = 6000,
                    burst = 2,
                    burstrate = 0.2,
                    damage = { default = 1100, vtol = 3200 },
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
                [1] = { def = 'LEGBASTION_W1_T7', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'LEGBASTION_W2_T7', onlytargetcategory = 'SURFACE' },
                [3] = { def = 'LEGBASTION_W3_T7', onlytargetcategory = 'VTOL' },
            },
        })
    end

    local newUnitNames = { 'armannit7', 'cordoomt7', 'legbastiont7' }

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
