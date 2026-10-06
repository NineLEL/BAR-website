-- AntiAirT4
-- Unique T4 End-Game Anti-Air Arsenal (Aegis Sky-Net Array, Flak-Storm Battery, Temporal Gravity-Snare)
-- https://github.com/nuttyb-community/nuttyb

do
    local uDefs, tMerge = UnitDefs or {}, table.merge

    local function addOpt(bName, opt)
        local b = uDefs[bName]
        if not b or not uDefs[opt] then return end
        b.buildoptions = b.buildoptions or {}
        for i = 1, #b.buildoptions do if b.buildoptions[i] == opt then return end end
        b.buildoptions[#b.buildoptions + 1] = opt
    end

    local function clone(src, tgt, ov)
        if uDefs[src] and not uDefs[tgt] then uDefs[tgt] = tMerge(uDefs[src], ov) end
    end

    local defaultDef = {
        allowNonBlockingAim = true,
        collidefriendly = 0,
        collidefeature = 0,
        avoidfeature = 0,
        avoidfriendly = 0,
        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
        cegtag = 'missiletrailaa',
        soundhit = 'xplomed1',
        soundstart = 'annigun1',
        rgbcolor = '0.2 0.8 1.0',
        rgbcolor2 = '0.8 0.9 1.0',
    }

    -- Armada Aegis Sky-Net Array
    local srcArmAA = uDefs['armflak'] and 'armflak' or (uDefs['armannit3'] and 'armannit3' or 'armgate')
    if uDefs[srcArmAA] then
        clone(srcArmAA, 'armaegisaa4', {
            name = 'T4 Aegis Sky-Net Array',
            description = 'T4 Heavy AA Battery - Multi-Target Tachyon Laser & Interceptor Missiles (catastrophic explosion)',
            metalcost = 42000,
            energycost = 850000,
            buildtime = 220000,
            health = 50000,
            footprintx = 7, footprintz = 7,
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Aegis Sky-Net Array',
                i18n_en_tooltip = 'High-altitude tachyon laser grid and long-range anti-boss interceptor missiles',
                techlevel = 4,
            },
            weapondefs = {
                AEGIS_TACHYON_AA = tMerge(defaultDef, {
                    name = 'Aegis Tachyon Chain Laser', weapontype = 'LaserCannon', range = 1800, reloadtime = 0.6,
                    energypershot = 6000, burst = 5, burstrate = 0.08, damage = { default = 1200, vtol = 6500 },
                    areaofeffect = 48, rgbcolor = '0.2 0.8 1.0', soundhit = 'xplomed1', soundstart = 'annigun1',
                    turret = true, weaponvelocity = 3200, thickness = 8, laserflaresize = 9
                }),
                AEGIS_MISSILE_AA = tMerge(defaultDef, {
                    name = 'Sky-Net Interceptor Missile', weapontype = 'MissileLauncher', range = 2200, reloadtime = 3.0,
                    energypershot = 15000, damage = { default = 3500, vtol = 18000 }, areaofeffect = 120,
                    soundhit = 'xplolrg2', soundstart = 'rockhvy1', turret = true, weaponvelocity = 2000,
                    tracks = true, turnrate = 35000
                })
            },
            weapons = {
                [1] = { def = 'AEGIS_TACHYON_AA', onlytargetcategory = 'VTOL' },
                [2] = { def = 'AEGIS_MISSILE_AA', onlytargetcategory = 'VTOL' }
            }
        })
    end

    -- Cortex Flak-Storm Battery
    local srcCorAA = uDefs['corflak'] and 'corflak' or (uDefs['cordoomt3'] and 'cordoomt3' or 'corgate')
    if uDefs[srcCorAA] then
        clone(srcCorAA, 'corflakstorm4', {
            name = 'T4 Flak-Storm Battery',
            description = 'T4 Super Flak Battery - Incendiary Flak & Paralyzing EMP Airburst (catastrophic explosion)',
            metalcost = 45000,
            energycost = 900000,
            buildtime = 240000,
            health = 55000,
            footprintx = 8, footprintz = 8,
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Flak-Storm Battery',
                i18n_en_tooltip = 'Super-heavy flak battery creating persistent sky-flame clouds and EMP stalls',
                techlevel = 4,
            },
            weapondefs = {
                FLAKSTORM_MAIN = tMerge(defaultDef, {
                    name = 'Incendiary Flak-Storm Shell', weapontype = 'Cannon', range = 1700, reloadtime = 0.5,
                    energypershot = 8000, firestarter = 100, damage = { default = 2500, vtol = 18000 },
                    areaofeffect = 450, soundhit = 'xplolrg1', soundstart = 'cannhvy2', turret = true, weaponvelocity = 2600
                }),
                FLAKSTORM_EMP = tMerge(defaultDef, {
                    name = 'EMP Airburst Flak', weapontype = 'Cannon', paralyzer = true, paralyzetime = 8,
                    range = 1500, reloadtime = 2.0, energypershot = 12000, damage = { default = 8000, vtol = 24000 },
                    areaofeffect = 350, soundhit = 'sizzle', soundstart = 'cannhvy1', turret = true, weaponvelocity = 2400
                })
            },
            weapons = {
                [1] = { def = 'FLAKSTORM_MAIN', onlytargetcategory = 'VTOL' },
                [2] = { def = 'FLAKSTORM_EMP', onlytargetcategory = 'VTOL' }
            }
        })
    end

    -- Legion Temporal Gravity-Snare
    local srcLegAA = uDefs['legflak'] and 'legflak' or (uDefs['legbastion'] and 'legbastion' or 'leggate')
    if uDefs[srcLegAA] then
        clone(srcLegAA, 'legsnareaa4', {
            name = 'T4 Temporal Gravity-Snare',
            description = 'T4 Gravity-Snare AA Array - Gravitational Pull & Stasis Freeze Beam (catastrophic explosion)',
            metalcost = 44000,
            energycost = 880000,
            buildtime = 230000,
            health = 52000,
            footprintx = 7, footprintz = 7,
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Temporal Gravity-Snare',
                i18n_en_tooltip = 'Gravitational anti-air array that drags airborne targets out of the sky',
                techlevel = 4,
            },
            weapondefs = {
                GRAVITY_SNARE_CANNON = tMerge(defaultDef, {
                    name = 'Gravity Well AA Cannon', weapontype = 'Cannon', range = 1700, reloadtime = 1.0,
                    energypershot = 10000, impulsefactor = -4.0, damage = { default = 2000, vtol = 15000 },
                    areaofeffect = 180, soundhit = 'xplolrg2', soundstart = 'laser2', turret = true, weaponvelocity = 2200
                }),
                STASIS_FREEZE_AA = tMerge(defaultDef, {
                    name = 'Temporal Stasis AA Beam', weapontype = 'BeamLaser', paralyzer = true, paralyzetime = 10,
                    range = 1200, reloadtime = 0.5, beamtime = 0.3, thickness = 6, energypershot = 8000,
                    damage = { default = 1800, vtol = 12000 }, areaofeffect = 80, soundhit = 'sizzle', soundstart = 'banthie2',
                    turret = true, weaponvelocity = 2000
                })
            },
            weapons = {
                [1] = { def = 'GRAVITY_SNARE_CANNON', onlytargetcategory = 'VTOL' },
                [2] = { def = 'STASIS_FREEZE_AA', onlytargetcategory = 'VTOL' }
            }
        })
    end

    local builders = {
        'armack', 'armaca', 'armacv', 'armt3airaide', 'armt3aide',
        'corack', 'coraca', 'coracv', 'cort3airaide', 'cort3aide',
        'legack', 'legaca', 'legacv', 'legt3airaide', 'legt3aide',
    }
    for i = 3, 10 do
        builders[#builders + 1] = 'armcomlvl' .. i
        builders[#builders + 1] = 'corcomlvl' .. i
        builders[#builders + 1] = 'legcomlvl' .. i
    end

    local uNames = { 'armaegisaa4', 'corflakstorm4', 'legsnareaa4' }
    for _, bName in pairs(builders) do
        local f = bName:sub(1, 3)
        for _, uName in ipairs(uNames) do
            if uName:sub(1, 3) == f then addOpt(bName, uName) end
        end
    end
end
