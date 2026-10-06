-- TitansT4
-- Mobile Super-Titans (Helios Tachyon Walker, Doomsday Dreadnought, Temporal Leviathan)
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
        explosiongenerator = 'custom:laserhit-large-blue',
        cegtag = '',
        soundhit = 'xplolrg3',
        soundstart = 'annihilator1',
        rgbcolor = '0.2 0.8 1.0',
        rgbcolor2 = '0.8 0.9 1.0',
    }

    -- Armada Helios Tachyon Walker
    if uDefs['armbanth'] then
        clone('armbanth', 'armheliost4', {
            name = 'T4 Helios Tachyon Walker',
            description = 'T4 Super-Titan Walker - Dual Tachyon Beams, Shield Aura & PD (catastrophic explosion)',
            metalcost = 85000,
            energycost = 1800000,
            buildtime = 450000,
            health = 120000,
            speed = 30,
            footprintx = 8, footprintz = 8,
            movementclass = 'HKBOT8',
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Helios Tachyon Walker',
                i18n_en_tooltip = 'Super-Titan walker projecting mobile plasma shields and twin tachyon beams',
                techlevel = 4,
            },
            weapondefs = {
                HELIOS_TACHYON = tMerge(defaultDef, {
                    name = 'Tachyon Disintegration Beam', weapontype = 'BeamLaser', largebeamlaser = true,
                    beamtime = 1.8, thickness = 12, corethickness = 0.5, laserflaresize = 14, scrollspeed = 5,
                    texture3 = 'largebeam', tilelength = 150, range = 1600, reloadtime = 3.0, energypershot = 80000,
                    damage = { default = 35000, commanders = 8000 }, areaofeffect = 180, rgbcolor = '0.2 0.8 1.0',
                    soundhit = 'xplolrg3', soundstart = 'annihilator1', turret = true, weaponvelocity = 2500
                }),
                HELIOS_PD = tMerge(defaultDef, {
                    name = 'Helios Heavy PD Laser', weapontype = 'BeamLaser', range = 750, reloadtime = 0.3,
                    beamtime = 0.2, thickness = 5, energypershot = 3000, damage = { default = 1800 }, areaofeffect = 48,
                    rgbcolor = '0.3 0.7 1.0', soundhit = 'sizzle', soundstart = 'beamershot2', turret = true, weaponvelocity = 2000
                })
            },
            weapons = {
                [1] = { def = 'HELIOS_TACHYON', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'HELIOS_PD', onlytargetcategory = 'SURFACE' }
            }
        })
    end

    -- Cortex Doomsday Dreadnought
    if uDefs['corgol'] or uDefs['cordoomt3'] then
        local src = uDefs['cordoomt3'] and 'cordoomt3' or 'corgol'
        clone(src, 'cordreadt4', {
            name = 'T4 Doomsday Dreadnought',
Description = 'T4 Super-Titan Siege Vehicle - Napalm Mortar, Heat Ray & Gatlings (catastrophic explosion)',
            metalcost = 95000,
            energycost = 2000000,
            buildtime = 500000,
            health = 150000,
            speed = 25,
            footprintx = 9, footprintz = 9,
            movementclass = 'HTANK9',
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Doomsday Dreadnought',
                i18n_en_tooltip = 'Heavy siege titan featuring armageddon heat ray and napalm cluster mortars',
                techlevel = 4,
            },
            weapondefs = {
                DREAD_HEATRAY = tMerge(defaultDef, {
                    name = 'Armageddon Heat Ray', weapontype = 'BeamLaser', largebeamlaser = true,
                    beamtime = 1.5, thickness = 10, range = 1450, reloadtime = 2.5, energypershot = 90000,
                    damage = { default = 40000, commanders = 9000 }, areaofeffect = 160, rgbcolor = '1.0 0.2 0.1',
                    soundhit = 'sizzle', soundstart = 'heatray2xl', turret = true, weaponvelocity = 2200
                }),
                DREAD_MORTAR = tMerge(defaultDef, {
                    name = 'Cluster Napalm Mortar', weapontype = 'Cannon', range = 1500, reloadtime = 4.0,
                    energypershot = 60000, projectiles = 5, sprayangle = 1000, firestarter = 100,
                    damage = { default = 25000 }, areaofeffect = 300, soundhit = 'xplolrg3', soundstart = 'cannhvy2', turret = true, weaponvelocity = 1800
                })
            },
            weapons = {
                [1] = { def = 'DREAD_HEATRAY', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'DREAD_MORTAR', onlytargetcategory = 'SURFACE' }
            }
        })
    end

    -- Legion Temporal Leviathan
    if uDefs['legbastion'] then
        clone('legbastion', 'legleviathant4', {
            name = 'T4 Temporal Leviathan',
            description = 'T4 Super-Titan Hover Tank - Antimatter Cannon & Stasis Field (catastrophic explosion)',
            metalcost = 90000,
            energycost = 1900000,
            buildtime = 480000,
            health = 135000,
            speed = 28,
            footprintx = 8, footprintz = 8,
            movementclass = 'HOVER8',
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Temporal Leviathan',
                i18n_en_tooltip = 'Hovering titan emitting stasis aura and antimatter spheres',
                techlevel = 4,
            },
            weapondefs = {
                LEVIATHAN_SPHERE = tMerge(defaultDef, {
                    name = 'Antimatter Sphere Cannon', weapontype = 'Cannon', range = 1500, reloadtime = 3.0,
                    energypershot = 85000, impulsefactor = 2.5, damage = { default = 38000 }, areaofeffect = 250,
                    soundhit = 'xplolrg2', soundstart = 'laser2', turret = true, weaponvelocity = 1800
                }),
                LEVIATHAN_STASIS = tMerge(defaultDef, {
                    name = 'Stasis Pulse Field', weapontype = 'Cannon', paralyzer = true, paralyzetime = 10,
                    range = 800, reloadtime = 3.5, energypershot = 30000, damage = { default = 20000, shields = 40000 },
                    areaofeffect = 500, soundhit = 'sizzle', soundstart = 'banthie2', turret = true, weaponvelocity = 1600
                })
            },
            weapons = {
                [1] = { def = 'LEVIATHAN_SPHERE', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'LEVIATHAN_STASIS', onlytargetcategory = 'SURFACE' }
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

    local uNames = { 'armheliost4', 'cordreadt4', 'legleviathant4' }
    for _, bName in pairs(builders) do
        local f = bName:sub(1, 3)
        for _, uName in ipairs(uNames) do
            if uName:sub(1, 3) == f then addOpt(bName, uName) end
        end
    end
end
