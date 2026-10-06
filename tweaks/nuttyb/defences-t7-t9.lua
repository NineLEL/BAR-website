-- ExtendedDefencesT7T9
-- Extended Super Defenses (T7-T9 Combined Compact Bundle)
do
    local uDefs, tMerge = UnitDefs or {}, table.merge

    local function addOpt(bName, opt)
        local b = uDefs[bName]
        if not b or not uDefs[opt] then return end
        b.buildoptions = b.buildoptions or {}
        for i = 1, #b.buildoptions do if b.buildoptions[i] == opt then return end end
        b.buildoptions[#b.buildoptions + 1] = opt
    end

    local function sc(v, m) return v and math.ceil(v * m) or nil end

    local function clone(src, tgt, ov)
        if uDefs[src] and not uDefs[tgt] then uDefs[tgt] = tMerge(uDefs[src], ov) end
    end

    local defaultDef = {
        allowNonBlockingAim = true,
        collidefriendly = 0,
        collidefeature = 0,
        avoidfeature = 0,
        avoidfriendly = 0,
        explosiongenerator = 'custom:genericshellexplosion-large-bomb',
        cegtag = '',
        soundhit = 'xplolrg3',
        soundstart = 'cannhvy2',
        rgbcolor = '0.8 0.2 1.0',
        rgbcolor2 = '0.9 0.4 1.0',
    }

    local cfg = {
        [7] = {
            cM = 100.0, hpM = 24.0, fpA = 8, fpC = 9, fpL = 8,
            dA = 'T7 Seismic Disruptor - Tectonic Cratering Wave, PD & AA',
            dC = 'T7 Bio-Mortar Array - Armor Melting MIRV, Spray & PD',
            dL = 'T7 Antimatter Cannon - Airburst Spheres, Paralyzer PD & AA',
            aW = {
                { def = { name = 'T7 Tectonic Shockwave Cannon', weapontype = 'Cannon', range = 1700, reloadtime = 3.0, energypershot = 150000, cylindertargeting = 1, cratermult = 3.0, impulsefactor = 3.0, damage = { default = 40000 }, areaofeffect = 300, soundhit = 'xplolrg3', soundstart = 'cannhvy1', turret = true, weaponvelocity = 1800 }, cat = 'SURFACE' },
                { def = { name = 'T7 Shockwave Point Defense', weapontype = 'Cannon', range = 800, reloadtime = 0.5, energypershot = 8000, cratermult = 1.5, damage = { default = 2000 }, areaofeffect = 80, soundhit = 'xplomed2', soundstart = 'cannhvy2', turret = true, weaponvelocity = 1500 }, cat = 'SURFACE' },
                { def = { name = 'T7 Tectonic AA Burst Laser', weapontype = 'LaserCannon', range = 1200, reloadtime = 1.0, energypershot = 6000, burst = 3, burstrate = 0.2, damage = { default = 1200, vtol = 3800 }, areaofeffect = 32, rgbcolor = '0.2 0.8 1.0', soundhit = 'xplomed1', soundstart = 'annigun1', turret = true, weaponvelocity = 2800, thickness = 7, laserflaresize = 8 }, cat = 'VTOL' }
            },
            cW = {
                { def = { name = 'T7 Corrupting MIRV Battery', weapontype = 'Cannon', range = 1700, reloadtime = 3.0, energypershot = 150000, projectiles = 5, sprayangle = 1500, damage = { default = 45000 }, areaofeffect = 400, soundhit = 'xplomed2', soundstart = 'cannhvy2', turret = true, weaponvelocity = 1800 }, cat = 'SURFACE' },
                { def = { name = 'T7 Corrosive Spray Ray', weapontype = 'BeamLaser', range = 900, reloadtime = 0.4, beamtime = 0.3, thickness = 6, energypershot = 10000, firestarter = 100, damage = { default = 2500 }, areaofeffect = 64, rgbcolor = '0.1 0.9 0.2', soundhit = 'sizzle', soundstart = 'heatray2xl', turret = true, weaponvelocity = 2000 }, cat = 'SURFACE' },
                { def = { name = 'T7 Bio-PD Laser', weapontype = 'BeamLaser', range = 600, reloadtime = 0.2, beamtime = 0.1, thickness = 4, energypershot = 3000, impactonly = 1, damage = { default = 1000 }, soundhit = 'sizzle', soundstart = 'beamershot2', turret = true, weaponvelocity = 1800 }, cat = 'SURFACE' }
            },
            lW = {
                { def = { name = 'T7 Antimatter Split Sphere', weapontype = 'Cannon', range = 1700, reloadtime = 3.0, energypershot = 140000, impulsefactor = 2.5, damage = { default = 42000 }, areaofeffect = 300, soundhit = 'xplolrg2', soundstart = 'laser2', turret = true, weaponvelocity = 1800 }, cat = 'SURFACE' },
                { def = { name = 'T7 Antimatter Paralyzer Laser', weapontype = 'BeamLaser', paralyzer = true, paralyzetime = 10, range = 750, reloadtime = 0.4, beamtime = 0.2, thickness = 5, energypershot = 5000, damage = { default = 1800 }, soundhit = 'sizzle', soundstart = 'banthie2', turret = true, weaponvelocity = 1800 }, cat = 'SURFACE' },
                { def = { name = 'T7 Split Cluster AA Battery', weapontype = 'Cannon', range = 1100, reloadtime = 0.8, energypershot = 6000, burst = 2, burstrate = 0.2, damage = { default = 1100, vtol = 3200 }, areaofeffect = 48, soundhit = 'xplomed2', soundstart = 'cannhvy1', turret = true, weaponvelocity = 2200 }, cat = 'VTOL' }
            }
        },
        [8] = {
            cM = 220.0, hpM = 48.0, fpA = 9, fpC = 10, fpL = 9,
            dA = 'T8 Sub-Space Array - Heavy Disintegration Beam, PD & AA',
            dC = 'T8 Supernova Battery - Heavy Plasma Shells, PD & Flak AA',
            dL = 'T8 Shield Nullifier - Heavy EMP Railgun, Grid PD & AA',
            aW = {
                { def = { name = 'T8 Sub-Space Disintegration Beam', weapontype = 'BeamLaser', largebeamlaser = true, beamtime = 1.5, thickness = 12, corethickness = 0.5, laserflaresize = 14, scrollspeed = 5, texture3 = 'largebeam', tilelength = 150, range = 1950, reloadtime = 3.5, energypershot = 350000, damage = { default = 75000, commanders = 15000 }, areaofeffect = 200, rgbcolor = '0.1 0.7 1.0', rgbcolor2 = '0.8 0.9 1.0', soundhit = 'xplolrg3', soundstart = 'annihilator1', turret = true, weaponvelocity = 2500 }, cat = 'SURFACE' },
                { def = { name = 'T8 Sub-Space Heavy PD', weapontype = 'BeamLaser', largebeamlaser = true, range = 900, reloadtime = 0.4, beamtime = 0.3, thickness = 6, corethickness = 0.35, energypershot = 12000, damage = { default = 3800 }, areaofeffect = 64, rgbcolor = '0.2 0.8 1.0', soundhit = 'xplomed2', soundstart = 'laser2', turret = true, weaponvelocity = 2000 }, cat = 'SURFACE' },
                { def = { name = 'T8 Disintegration AA Cannon', weapontype = 'LaserCannon', range = 1400, reloadtime = 1.0, energypershot = 15000, burst = 4, burstrate = 0.15, damage = { default = 2200, vtol = 6000 }, areaofeffect = 48, rgbcolor = '0.1 0.7 1.0', soundhit = 'xplomed1', soundstart = 'annigun1', turret = true, weaponvelocity = 3000, thickness = 8, laserflaresize = 9 }, cat = 'VTOL' }
            },
            cW = {
                { def = { name = 'T8 Supernova Plasma Shell', weapontype = 'Cannon', range = 1950, reloadtime = 3.5, energypershot = 350000, projectiles = 6, sprayangle = 1000, cratermult = 3.0, damage = { default = 80000 }, areaofeffect = 500, soundhit = 'xplolrg3', soundstart = 'cannhvy2', turret = true, weaponvelocity = 2000 }, cat = 'SURFACE' },
                { def = { name = 'T8 Supernova Thermal PD', weapontype = 'Cannon', range = 800, reloadtime = 0.5, energypershot = 10000, firestarter = 100, damage = { default = 3000 }, areaofeffect = 96, soundhit = 'xplomed2', soundstart = 'cannhvy1', turret = true, weaponvelocity = 1500 }, cat = 'SURFACE' },
                { def = { name = 'T8 Plasma Flak AA Battery', weapontype = 'Cannon', range = 1300, reloadtime = 0.6, energypershot = 12000, damage = { default = 1500, vtol = 5000 }, areaofeffect = 120, soundhit = 'xplolrg1', soundstart = 'cannhvy2', turret = true, weaponvelocity = 2400 }, cat = 'VTOL' }
            },
            lW = {
                { def = { name = 'T8 Shield Nullifier Railgun', weapontype = 'Cannon', paralyzer = true, paralyzetime = 20, range = 1950, reloadtime = 3.5, energypershot = 330000, impulsefactor = -3.0, damage = { default = 75000, commanders = 15000 }, areaofeffect = 600, soundhit = 'xplomed2', soundstart = 'laser2', turret = true, weaponvelocity = 2000 }, cat = 'SURFACE' },
                { def = { name = 'T8 Grid Collapse PD Beam', weapontype = 'BeamLaser', paralyzer = true, paralyzetime = 12, range = 900, reloadtime = 0.4, beamtime = 0.2, thickness = 5, energypershot = 10000, damage = { default = 3200 }, areaofeffect = 64, soundhit = 'sizzle', soundstart = 'banthie2', turret = true, weaponvelocity = 2000 }, cat = 'SURFACE' },
                { def = { name = 'T8 Nullifier AA Burst Railgun', weapontype = 'Cannon', range = 1350, reloadtime = 0.8, energypershot = 14000, burst = 3, burstrate = 0.15, damage = { default = 1800, vtol = 5500 }, areaofeffect = 64, soundhit = 'xplomed2', soundstart = 'cannhvy1', turret = true, weaponvelocity = 2400 }, cat = 'VTOL' }
            }
        },
        [9] = {
            cM = 500.0, hpM = 105.0, fpA = 10, fpC = 12, fpL = 10,
            dA = 'T9 Celestial Nova Array - Orbital Tachyon Death-Ray, PD & AA',
            dC = 'T9 Apocalypse Hellfire Battery - Nuclear Shell Cannon, PD & Flak AA',
            dL = 'T9 Cosmic Event Horizon Emitter - Antimatter Beam, Paralyzer PD & AA',
            aW = {
                { def = { name = 'T9 Celestial Tachyon Death-Ray', weapontype = 'BeamLaser', largebeamlaser = true, beamtime = 2.5, thickness = 16, corethickness = 0.6, laserflaresize = 16, scrollspeed = 6, texture3 = 'largebeam', tilelength = 150, range = 2200, reloadtime = 4.0, energypershot = 800000, damage = { default = 120000 }, areaofeffect = 400, cratermult = 3.0, rgbcolor = '1.0 0.2 0.8', rgbcolor2 = '1.0 0.8 0.9', soundhit = 'xplolrg3', soundstart = 'annihilator1', turret = true, weaponvelocity = 3000 }, cat = 'SURFACE' },
                { def = { name = 'T9 Celestial Heavy PD', weapontype = 'BeamLaser', largebeamlaser = true, range = 1000, reloadtime = 0.3, beamtime = 0.2, thickness = 8, corethickness = 0.4, energypershot = 20000, damage = { default = 7000 }, areaofeffect = 80, rgbcolor = '0.8 0.2 1.0', soundhit = 'xplomed2', soundstart = 'laser2', turret = true, weaponvelocity = 2200 }, cat = 'SURFACE' },
                { def = { name = 'T9 Celestial AA Array', weapontype = 'LaserCannon', range = 1600, reloadtime = 0.8, energypershot = 25000, burst = 5, burstrate = 0.1, damage = { default = 3500, vtol = 10000 }, areaofeffect = 64, rgbcolor = '0.1 0.5 1.0', soundhit = 'xplomed1', soundstart = 'annigun1', turret = true, weaponvelocity = 3200, thickness = 10, laserflaresize = 12 }, cat = 'VTOL' }
            },
            cW = {
                { def = { name = 'T9 Nuclear Hellfire Shell', weapontype = 'Cannon', range = 2200, reloadtime = 4.0, energypershot = 800000, damage = { default = 130000 }, areaofeffect = 700, cratermult = 4.0, explosiongenerator = 'custom:genericshellexplosion-huge-bomb', soundhit = 'xplolrg3', soundstart = 'cannhvy2', turret = true, weaponvelocity = 2200 }, cat = 'SURFACE' },
                { def = { name = 'T9 Apocalypse Thermal PD', weapontype = 'Cannon', range = 900, reloadtime = 0.4, energypershot = 18000, firestarter = 100, damage = { default = 5000 }, areaofeffect = 120, soundhit = 'xplomed2', soundstart = 'cannhvy1', turret = true, weaponvelocity = 1800 }, cat = 'SURFACE' },
                { def = { name = 'T9 Hellfire Flak AA', weapontype = 'Cannon', range = 1500, reloadtime = 0.5, energypershot = 22000, damage = { default = 3000, vtol = 9000 }, areaofeffect = 150, soundhit = 'xplolrg1', soundstart = 'cannhvy2', turret = true, weaponvelocity = 2600 }, cat = 'SURFACE' }
            },
            lW = {
                { def = { name = 'T9 Event Horizon Disintegrator', weapontype = 'BeamLaser', largebeamlaser = true, beamtime = 2.0, thickness = 14, corethickness = 0.5, laserflaresize = 15, scrollspeed = 5, texture3 = 'largebeam', tilelength = 150, range = 2200, reloadtime = 4.0, energypershot = 800000, damage = { default = 125000 }, areaofeffect = 500, rgbcolor = '0.9 0.1 0.2', rgbcolor2 = '1.0 0.6 0.2', soundhit = 'xplolrg3', soundstart = 'laser2', turret = true, weaponvelocity = 2500 }, cat = 'SURFACE' },
                { def = { name = 'T9 Event Horizon Paralyzer PD', weapontype = 'BeamLaser', paralyzer = true, paralyzetime = 15, range = 950, reloadtime = 0.3, beamtime = 0.2, thickness = 6, energypershot = 16000, damage = { default = 4500 }, areaofeffect = 80, soundhit = 'sizzle', soundstart = 'banthie2', turret = true, weaponvelocity = 2200 }, cat = 'SURFACE' },
                { def = { name = 'T9 Cosmic AA Burst', weapontype = 'Cannon', range = 1500, reloadtime = 0.7, energypershot = 20000, burst = 4, burstrate = 0.1, damage = { default = 2800, vtol = 8500 }, areaofeffect = 80, soundhit = 'xplomed2', soundstart = 'cannhvy1', turret = true, weaponvelocity = 2600 }, cat = 'VTOL' }
            }
        }
    }

    local uNames = {}

    local function makeFactionUnits(tier, tCfg, baseName, unitPrefix, nameKey, descKey, wListKey, fpKey)
        if not uDefs[baseName] then return end
        local uName = unitPrefix .. tier
        local base = uDefs[baseName]
        local wDefs, wList = {}, {}
        for idx, wInfo in ipairs(tCfg[wListKey]) do
            local defKey = nameKey .. idx .. '_T' .. tier
            wDefs[defKey] = tMerge(defaultDef, wInfo.def)
            wList[idx] = { def = defKey, onlytargetcategory = wInfo.cat }
        end
        local hName = tCfg[descKey]:match('^(T%d [^-]+)')
        clone(baseName, uName, {
            name = hName,
            description = tCfg[descKey] .. ' (catastrophic explosion)',
            metalcost = sc(base.metalcost, tCfg.cM),
            energycost = sc(base.energycost, tCfg.cM),
            buildtime = sc(base.buildtime, tCfg.cM),
            health = sc(base.health, tCfg.hpM),
            footprintx = tCfg[fpKey], footprintz = tCfg[fpKey],
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = { i18n_en_humanname = hName, i18n_en_tooltip = tCfg[descKey], techlevel = tier },
            weapondefs = wDefs, weapons = wList
        })
        table.insert(uNames, uName)
    end

    for tier = 7, 9 do
        local t = cfg[tier]
        makeFactionUnits(tier, t, 'armannit3', 'armannit', 'ARMANNI_W', 'dA', 'aW', 'fpA')
        makeFactionUnits(tier, t, 'cordoomt3', 'cordoomt', 'CORDOOM_W', 'dC', 'cW', 'fpC')
        makeFactionUnits(tier, t, 'legbastion', 'legbastiont', 'LEGBASTION_W', 'dL', 'lW', 'fpL')
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

    for _, bName in pairs(builders) do
        local f = bName:sub(1, 3)
        for _, uName in ipairs(uNames) do
            if uName:sub(1, 3) == f then addOpt(bName, uName) end
        end
    end
end
