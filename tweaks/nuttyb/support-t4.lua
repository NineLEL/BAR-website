-- SupportT4
-- Area Defense & Support Structures (Super Shield Generators, Repair Hubs, Quantum Radar)
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

    local factions = { 'arm', 'cor', 'leg' }

    for _, f in ipairs(factions) do
        -- 1. Super Plasma Shield Generator
        local srcShield = f .. 'gate'
        if not uDefs[srcShield] then srcShield = 'armgate' end
        if uDefs[srcShield] then
            clone(srcShield, f .. 'shieldt4', {
                name = 'T4 Super Shield Generator',
                description = 'T4 Base Plasma Shield - Covers 1800 radius, 250,000 power (large explosion)',
                metalcost = 45000,
                energycost = 900000,
                buildtime = 250000,
                health = 60000,
                footprintx = 8, footprintz = 8,
                explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = 'T4 Super Shield Generator',
                    i18n_en_tooltip = 'Projects a high-capacity base-wide plasma shield',
                    techlevel = 4,
                },
                shieldpower = 250000,
                shieldpowerregen = 3500,
                shieldpowerregenenergy = 15000,
                shieldradius = 1800,
            })
        end

        -- 2. Automated Reconstruction Hub
        local srcRepair = f == 'leg' and 'legnanotc' or (f .. 'nanotc')
        if not uDefs[srcRepair] then srcRepair = 'armnanotc' end
        if uDefs[srcRepair] then
            clone(srcRepair, f .. 'repairt4', {
                name = 'T4 Reconstruction Hub',
                description = 'T4 Nanite Repair & Reconstruction Hub - 1200 range, 8000 workertime (large explosion)',
                metalcost = 38000,
                energycost = 750000,
                buildtime = 200000,
                health = 45000,
                workertime = 8000,
                builddistance = 1200,
                footprintx = 7, footprintz = 7,
                explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = 'T4 Reconstruction Hub',
                    i18n_en_tooltip = 'High-capacity repair hub that rapidly fixes and reconstructs allied structures',
                    techlevel = 4,
                },
            })
        end

        -- 3. Quantum Radar & Target Designator
        local srcRadar = f .. 'rad'
        if not uDefs[srcRadar] then srcRadar = 'armrad' end
        if uDefs[srcRadar] then
            clone(srcRadar, f .. 'radart4', {
                name = 'T4 Quantum Radar Hub',
                description = 'T4 Quantum Radar & Target Designator - 3500 stealth-piercing coverage',
                metalcost = 25000,
                energycost = 500000,
                buildtime = 150000,
                health = 35000,
                radardistance = 3500,
                sonardistance = 3500,
                radardistancejam = 1500,
                sonardistancejam = 1500,
                seismicdistance = 2500,
                footprintx = 6, footprintz = 6,
                explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = 'T4 Quantum Radar Hub',
                    i18n_en_tooltip = 'Provides map-wide stealth-piercing radar, jammer & seismic target acquisition',
                    techlevel = 4,
                },
            })
        end

        -- 4. T4 Resource Protection Citadel
        local srcGate = f .. 'gate'
        if not uDefs[srcGate] then srcGate = 'armgate' end
        if uDefs[srcGate] then
            local defWeaponKey = 'CITADEL_BEAM_' .. f:upper()
            local defWeapon = {
                name = 'Citadel Point Defense Beam',
                weapontype = 'BeamLaser',
                largebeamlaser = true,
                beamtime = 0.5,
                thickness = 6,
                corethickness = 0.4,
                range = 750,
                reloadtime = 1.0,
                energypershot = 1000,
                damage = { default = 2500 },
                areaofeffect = 64,
                rgbcolor = '0.2 0.8 1.0',
                rgbcolor2 = '0.8 0.9 1.0',
                explosiongenerator = 'custom:laserhit-large-blue',
                cegtag = '',
                soundhit = 'xplomed2',
                soundstart = 'beamershot2',
                turret = true,
                weaponvelocity = 2000,
                allowNonBlockingAim = true,
                collidefriendly = 0, collidefeature = 0, avoidfeature = 0, avoidfriendly = 0,
            }

            local baseGateDef = uDefs[srcGate]
            local inheritedWeaponDefs = baseGateDef.weapondefs or {}

            clone(srcGate, f .. 'citadelt4', {
                name = 'T4 Resource Protection Citadel',
                description = 'T4 Resource Protection Structure - Local Shield, Repair Power & Light PD',
                metalcost = 32000,
                energycost = 650000,
                buildtime = 180000,
                health = 40000,
                workertime = 1500,
                builddistance = 800,
                shieldpower = 120000,
                shieldpowerregen = 2000,
                shieldpowerregenenergy = 8000,
                shieldradius = 900,
                footprintx = 7, footprintz = 7,
                explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
                weapondefs = tMerge(inheritedWeaponDefs, {
                    [defWeaponKey] = defWeapon,
                }),
                customparams = {
                    i18n_en_humanname = 'T4 Resource Protection Citadel',
                    i18n_en_tooltip = 'Protects high-tier eco with localized plasma shield, repair aura and point defense',
                    techlevel = 4,
                },
            })
        end
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

    local uNames = {
        'armshieldt4', 'corshieldt4', 'legshieldt4',
        'armrepairt4', 'correpairt4', 'legrepairt4',
        'armradart4', 'corradart4', 'legradart4',
        'armcitadelt4', 'corcitadelt4', 'legcitadelt4'
    }
    for _, bName in pairs(builders) do
        local f = bName:sub(1, 3)
        for _, uName in ipairs(uNames) do
            if uName:sub(1, 3) == f then addOpt(bName, uName) end
        end
    end
end
