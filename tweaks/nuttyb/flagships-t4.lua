-- FlagshipsT4
-- Airborne Flagships & Drone Carriers (Sky Fortress, Heavy Gunship Battleship, Temporal Stasis Dreadnought)
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
        soundhit = 'xplolrg2',
        soundstart = 'annigun1',
        rgbcolor = '0.2 0.8 1.0',
        rgbcolor2 = '0.8 0.9 1.0',
    }

    -- Armada Sky Fortress & Drone Carrier
    local srcArmFly = uDefs['armsark'] and 'armsark' or (uDefs['armpeep'] and 'armpeep' or 'armannit3')
    if uDefs[srcArmFly] then
        clone(srcArmFly, 'armcarriert4', {
            name = 'T4 Sky Fortress Carrier',
            description = 'T4 Flying Fortress & Carrier - Flying Repair Aura, Drone Bay & Quad Lasers (catastrophic explosion)',
            metalcost = 70000,
            energycost = 1500000,
            buildtime = 380000,
            health = 80000,
            speed = 40,
            canfly = true,
            cruisealt = 350,
            workertime = 3000,
            footprintx = 8, footprintz = 8,
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Sky Fortress Carrier',
                i18n_en_tooltip = 'Airborne flagship carrying autonomous interceptor drones and in-flight repair aura',
                techlevel = 4,
            },
            weapondefs = {
                FORTRESS_AA = tMerge(defaultDef, {
                    name = 'Quad AA Pulse Laser', weapontype = 'LaserCannon', range = 1400, reloadtime = 0.8,
                    energypershot = 8000, burst = 4, burstrate = 0.1, damage = { default = 2500, vtol = 8000 },
                    areaofeffect = 48, rgbcolor = '0.2 0.8 1.0', soundhit = 'xplomed1', soundstart = 'annigun1',
                    turret = true, weaponvelocity = 3000, thickness = 7, laserflaresize = 8
                }),
                FORTRESS_BOMB = tMerge(defaultDef, {
                    name = 'Tachyon Carpet Bomb', weapontype = 'AircraftBomb', range = 500, reloadtime = 4.0,
                    energypershot = 25000, damage = { default = 18000 }, areaofeffect = 250, soundhit = 'xplolrg2'
                })
            },
            weapons = {
                [1] = { def = 'FORTRESS_AA', onlytargetcategory = 'VTOL' },
                [2] = { def = 'FORTRESS_BOMB', onlytargetcategory = 'SURFACE' }
            }
        })
    end

    -- Cortex Heavy Gunship Battleship
    local srcCorFly = uDefs['corkrow'] and 'corkrow' or (uDefs['corpeep'] and 'corpeep' or 'cordoomt3')
    if uDefs[srcCorFly] then
        clone(srcCorFly, 'corgunshipt4', {
            name = 'T4 Heavy Gunship Battleship',
            description = 'T4 Airborne Battleship - Triple Plasma Cannons, Napalm Bombs & Thermal PD (catastrophic explosion)',
            metalcost = 80000,
            energycost = 1700000,
            buildtime = 420000,
            health = 95000,
            speed = 35,
            canfly = true,
            cruisealt = 320,
            footprintx = 9, footprintz = 9,
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Heavy Gunship Battleship',
                i18n_en_tooltip = 'Flying fortress packed with heavy plasma cannons and carpet napalm bomb bays',
                techlevel = 4,
            },
            weapondefs = {
                GUNSHIP_CANNON = tMerge(defaultDef, {
                    name = 'Airborne Plasma Cannon', weapontype = 'Cannon', range = 1300, reloadtime = 2.0,
                    energypershot = 35000, projectiles = 3, sprayangle = 600, damage = { default = 22000 },
                    areaofeffect = 220, soundhit = 'xplolrg3', soundstart = 'cannhvy2', turret = true, weaponvelocity = 1800
                }),
                GUNSHIP_NAPALM = tMerge(defaultDef, {
                    name = 'Carpet Napalm Bay', weapontype = 'AircraftBomb', range = 600, reloadtime = 5.0,
                    energypershot = 40000, firestarter = 100, damage = { default = 25000 }, areaofeffect = 350, soundhit = 'xplolrg2'
                })
            },
            weapons = {
                [1] = { def = 'GUNSHIP_CANNON', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'GUNSHIP_NAPALM', onlytargetcategory = 'SURFACE' }
            }
        })
    end

    -- Legion Temporal Stasis Dreadnought
    local srcLegFly = uDefs['legpeep'] and 'legpeep' or (uDefs['legaca'] and 'legaca' or 'legbastion')
    if uDefs[srcLegFly] then
        clone(srcLegFly, 'leggunshipt4', {
            name = 'T4 Temporal Stasis Dreadnought',
            description = 'T4 Airborne Stasis Dreadnought - Antimatter Bomb Bay & Paralyzer Beam (catastrophic explosion)',
            metalcost = 75000,
            energycost = 1600000,
            buildtime = 400000,
            health = 85000,
            speed = 38,
            canfly = true,
            cruisealt = 340,
            movementclass = nil,
            footprintx = 8, footprintz = 8,
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Temporal Stasis Dreadnought',
                i18n_en_tooltip = 'Airborne dreadnought emitting paralyzing stasis beams and antimatter cluster bombs',
                techlevel = 4,
            },
            weapondefs = {
                STASIS_FLY_BEAM = tMerge(defaultDef, {
                    name = 'Airborne Paralyzer Beam', weapontype = 'BeamLaser', paralyzer = true, paralyzetime = 10,
                    range = 1000, reloadtime = 1.0, beamtime = 0.5, thickness = 6, energypershot = 20000,
                    damage = { default = 15000 }, areaofeffect = 100, soundhit = 'sizzle', soundstart = 'banthie2', turret = true, weaponvelocity = 2000
                }),
                STASIS_FLY_BOMB = tMerge(defaultDef, {
                    name = 'Antimatter Cluster Bomb', weapontype = 'AircraftBomb', range = 500, reloadtime = 4.5,
                    energypershot = 30000, impulsefactor = 2.0, damage = { default = 20000 }, areaofeffect = 300, soundhit = 'xplolrg2'
                })
            },
            weapons = {
                [1] = { def = 'STASIS_FLY_BEAM', onlytargetcategory = 'SURFACE' },
                [2] = { def = 'STASIS_FLY_BOMB', onlytargetcategory = 'SURFACE' }
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

    local uNames = { 'armcarriert4', 'corgunshipt4', 'leggunshipt4' }
    for _, bName in pairs(builders) do
        local f = bName:sub(1, 3)
        for _, uName in ipairs(uNames) do
            if uName:sub(1, 3) == f then addOpt(bName, uName) end
        end
    end
end
