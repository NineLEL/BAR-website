-- ExtendedDefencesT5T6
-- Extended Super Defenses (T5-T6 Combined Compact Bundle)
-- https://github.com/nuttyb-community/nuttyb

do
    local unitDefs = UnitDefs or {}
    local tableMerge = table.merge

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

    local defaultDef = {
        allowNonBlockingAim = true,
        collidefriendly = 0,
        collidefeature = 0,
        avoidfeature = 0,
        avoidfriendly = 0,
        turret = true,
        cegtag = '',
        soundhit = 'xplomed2',
        soundstart = 'annigun1',
    }

    local function makeWDef(ov)
        return tableMerge(defaultDef, ov)
    end

    local tierConfigs = {
        [5] = {
            costMult = 2.5,
            hpMult = 2.0,
            fpArm = 6,
            fpCor = 7,
            fpLeg = 6,
            descArm = 'T5 Pulsar Array - Rapid tachyon beams, PD & AA',
            descCor = 'T5 Hellstorm Battery - Cluster shells, flame PD & flak AA',
            descLeg = 'T5 Void Emitter - Gravity cannon, stasis PD & AA',
            armWeapons = {
                [1] = {
                    def = makeWDef({
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
                        rgbcolor2 = '0.9 0.4 1.0',
                        explosiongenerator = 'custom:laserhit-large-blue',
                        soundhit = 'xplolrg2',
                        soundstart = 'annihilator1',
                        weaponvelocity = 2000,
                    }),
                    cat = 'SURFACE',
                },
                [2] = {
                    def = makeWDef({
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
                        rgbcolor2 = '0.8 0.9 1.0',
                        explosiongenerator = 'custom:laserhit-small-blue',
                        soundhit = 'sizzle',
                        soundstart = 'beamershot2',
                        weaponvelocity = 1800,
                    }),
                    cat = 'SURFACE',
                },
                [3] = {
                    def = makeWDef({
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
                        rgbcolor2 = '0.8 0.9 1.0',
                        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
                        cegtag = 'missiletrailaa',
                        soundhit = 'xplomed1',
                        weaponvelocity = 2500,
                        thickness = 5,
                        laserflaresize = 6,
                    }),
                    cat = 'VTOL',
                },
            },
            corWeapons = {
                [1] = {
                    def = makeWDef({
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
                        rgbcolor = '1.0 0.5 0.2',
                        rgbcolor2 = '1.0 0.8 0.4',
                        explosiongenerator = 'custom:genericshellexplosion-large-bomb',
                        soundhit = 'xplolrg2',
                        soundstart = 'cannhvy2',
                        weaponvelocity = 1600,
                    }),
                    cat = 'SURFACE',
                },
                [2] = {
                    def = makeWDef({
                        name = 'T5 Inferno Point Defense',
                        weapontype = 'Cannon',
                        range = 600,
                        reloadtime = 0.5,
                        energypershot = 3000,
                        firestarter = 80,
                        damage = { default = 800 },
                        areaofeffect = 64,
                        rgbcolor = '1.0 0.4 0.1',
                        rgbcolor2 = '1.0 0.7 0.3',
                        explosiongenerator = 'custom:genericshellexplosion-medium-bomb',
                        soundstart = 'cannhvy1',
                        weaponvelocity = 1200,
                    }),
                    cat = 'SURFACE',
                },
                [3] = {
                    def = makeWDef({
                        name = 'T5 Hellstorm Flak AA',
                        weapontype = 'Cannon',
                        range = 900,
                        reloadtime = 0.8,
                        energypershot = 3500,
                        damage = { default = 600, vtol = 2000 },
                        areaofeffect = 80,
                        rgbcolor = '1.0 0.5 0.2',
                        rgbcolor2 = '1.0 0.8 0.4',
                        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
                        cegtag = 'missiletrailaa',
                        soundhit = 'xplolrg1',
                        soundstart = 'cannhvy2',
                        weaponvelocity = 2000,
                    }),
                    cat = 'VTOL',
                },
            },
            legWeapons = {
                [1] = {
                    def = makeWDef({
                        name = 'T5 Gravity Well Cannon',
                        weapontype = 'Cannon',
                        range = 1350,
                        reloadtime = 2.5,
                        energypershot = 38000,
                        impulsefactor = 2.0,
                        damage = { default = 11000 },
                        areaofeffect = 160,
                        rgbcolor = '0.5 0.2 0.9',
                        rgbcolor2 = '0.8 0.5 1.0',
                        explosiongenerator = 'custom:genericshellexplosion-large-bomb',
                        soundhit = 'xplolrg2',
                        soundstart = 'laser2',
                        weaponvelocity = 1500,
                    }),
                    cat = 'SURFACE',
                },
                [2] = {
                    def = makeWDef({
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
                        rgbcolor = '0.4 0.2 0.8',
                        rgbcolor2 = '0.7 0.5 1.0',
                        explosiongenerator = 'custom:laserhit-small-purple',
                        soundhit = 'sizzle',
                        soundstart = 'banthie2',
                        weaponvelocity = 1800,
                    }),
                    cat = 'SURFACE',
                },
                [3] = {
                    def = makeWDef({
                        name = 'T5 Void AA Burst',
                        weapontype = 'Cannon',
                        range = 850,
                        reloadtime = 0.9,
                        energypershot = 2800,
                        burst = 2,
                        burstrate = 0.2,
                        damage = { default = 500, vtol = 1600 },
                        areaofeffect = 36,
                        rgbcolor = '0.5 0.2 0.9',
                        rgbcolor2 = '0.8 0.5 1.0',
                        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
                        cegtag = 'missiletrailaa',
                        soundstart = 'cannhvy1',
                        weaponvelocity = 2000,
                    }),
                    cat = 'VTOL',
                },
            },
        },
        [6] = {
            costMult = 5.0,
            hpMult = 4.0,
            fpArm = 7,
            fpCor = 8,
            fpLeg = 7,
            descArm = 'T6 Nova Cannon - Heavy disintegration beam, PD & AA',
            descCor = 'T6 Magma Battery - Heavy plasma shells, thermal PD & flak AA',
            descLeg = 'T6 Rift Emitter - EMP railgun, paralyzer PD & AA',
            armWeapons = {
                [1] = {
                    def = makeWDef({
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
                        explosiongenerator = 'custom:laserhit-large-purple',
                        soundhit = 'xplolrg3',
                        weaponvelocity = 2200,
                    }),
                    cat = 'SURFACE',
                },
                [2] = {
                    def = makeWDef({
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
                        rgbcolor2 = '0.8 0.5 1.0',
                        explosiongenerator = 'custom:laserhit-medium-purple',
                        soundstart = 'laser2',
                        weaponvelocity = 1800,
                    }),
                    cat = 'SURFACE',
                },
                [3] = {
                    def = makeWDef({
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
                        rgbcolor2 = '0.7 0.8 1.0',
                        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
                        cegtag = 'missiletrailaa',
                        soundhit = 'xplomed1',
                        weaponvelocity = 2600,
                        thickness = 6,
                        laserflaresize = 7,
                    }),
                    cat = 'VTOL',
                },
            },
            corWeapons = {
                [1] = {
                    def = makeWDef({
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
                        rgbcolor = '1.0 0.4 0.1',
                        rgbcolor2 = '1.0 0.7 0.3',
                        explosiongenerator = 'custom:genericshellexplosion-large-bomb',
                        soundhit = 'xplolrg3',
                        soundstart = 'cannhvy2',
                        weaponvelocity = 1700,
                    }),
                    cat = 'SURFACE',
                },
                [2] = {
                    def = makeWDef({
                        name = 'T6 Thermal Point Defense',
                        weapontype = 'Cannon',
                        range = 700,
                        reloadtime = 0.5,
                        energypershot = 5500,
                        firestarter = 100,
                        damage = { default = 1600 },
                        areaofeffect = 80,
                        rgbcolor = '1.0 0.5 0.2',
                        rgbcolor2 = '1.0 0.8 0.4',
                        explosiongenerator = 'custom:genericshellexplosion-medium-bomb',
                        soundstart = 'cannhvy1',
                        weaponvelocity = 1400,
                    }),
                    cat = 'SURFACE',
                },
                [3] = {
                    def = makeWDef({
                        name = 'T6 Magma Flak AA',
                        weapontype = 'Cannon',
                        range = 1050,
                        reloadtime = 0.7,
                        energypershot = 5000,
                        damage = { default = 1000, vtol = 3500 },
                        areaofeffect = 100,
                        rgbcolor = '1.0 0.5 0.2',
                        rgbcolor2 = '1.0 0.8 0.4',
                        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
                        cegtag = 'missiletrailaa',
                        soundhit = 'xplolrg1',
                        soundstart = 'cannhvy2',
                        weaponvelocity = 2200,
                    }),
                    cat = 'VTOL',
                },
            },
            legWeapons = {
                [1] = {
                    def = makeWDef({
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
                        rgbcolor = '0.5 0.2 0.9',
                        rgbcolor2 = '0.8 0.5 1.0',
                        explosiongenerator = 'custom:genericshellexplosion-large-bomb',
                        soundstart = 'laser2',
                        weaponvelocity = 1800,
                    }),
                    cat = 'SURFACE',
                },
                [2] = {
                    def = makeWDef({
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
                        rgbcolor = '0.6 0.2 0.9',
                        rgbcolor2 = '0.8 0.5 1.0',
                        explosiongenerator = 'custom:laserhit-small-purple',
                        soundhit = 'sizzle',
                        soundstart = 'banthie2',
                        weaponvelocity = 1800,
                    }),
                    cat = 'SURFACE',
                },
                [3] = {
                    def = makeWDef({
                        name = 'T6 Rift AA Burst',
                        weapontype = 'Cannon',
                        range = 1000,
                        reloadtime = 0.8,
                        energypershot = 4500,
                        burst = 3,
                        burstrate = 0.15,
                        damage = { default = 800, vtol = 3000 },
                        areaofeffect = 48,
                        rgbcolor = '0.5 0.2 0.9',
                        rgbcolor2 = '0.8 0.5 1.0',
                        explosiongenerator = 'custom:genericshellexplosion-tiny-aa',
                        cegtag = 'missiletrailaa',
                        soundstart = 'cannhvy1',
                        weaponvelocity = 2200,
                    }),
                    cat = 'VTOL',
                },
            },
        },
    }

    local newUnitNames = {}

    for tier = 5, 6 do
        local cfg = tierConfigs[tier]

        if unitDefs['armannit3'] then
            local uName = 'armannit' .. tier
            local base = unitDefs['armannit3']
            local wDefs, wList = {}, {}
            for idx, wInfo in ipairs(cfg.armWeapons) do
                local defKey = ('ARMANNI_W%d_T%d'):format(idx, tier)
                wDefs[defKey] = tableMerge(defaultDef, wInfo.def)
                wList[idx] = { def = defKey, onlytargetcategory = wInfo.cat }
            end
            cloneUnit('armannit3', uName, {
                name = cfg.descArm:match('^(T%d [^-]+)'),
                description = cfg.descArm .. ' (large explosion)',
                metalcost = scaled(base.metalcost, cfg.costMult * 10),
                energycost = scaled(base.energycost, cfg.costMult * 10),
                buildtime = scaled(base.buildtime, cfg.costMult * 10),
                health = scaled(base.health, cfg.hpMult * 3),
                footprintx = cfg.fpArm,
                footprintz = cfg.fpArm,
                explodeas = 'advancedFusionExplosion',
                selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = cfg.descArm:match('^(T%d [^-]+)'),
                    i18n_en_tooltip = cfg.descArm,
                    techlevel = tier,
                },
                weapondefs = wDefs,
                weapons = wList,
            })
            table.insert(newUnitNames, uName)
        end

        if unitDefs['cordoomt3'] then
            local uName = 'cordoomt' .. tier
            local base = unitDefs['cordoomt3']
            local wDefs, wList = {}, {}
            for idx, wInfo in ipairs(cfg.corWeapons) do
                local defKey = ('CORDOOM_W%d_T%d'):format(idx, tier)
                wDefs[defKey] = tableMerge(defaultDef, wInfo.def)
                wList[idx] = { def = defKey, onlytargetcategory = wInfo.cat }
            end
            cloneUnit('cordoomt3', uName, {
                name = cfg.descCor:match('^(T%d [^-]+)'),
                description = cfg.descCor .. ' (large explosion)',
                metalcost = scaled(base.metalcost, cfg.costMult * 10),
                energycost = scaled(base.energycost, cfg.costMult * 10),
                buildtime = scaled(base.buildtime, cfg.costMult * 10),
                health = scaled(base.health, cfg.hpMult * 3),
                footprintx = cfg.fpCor,
                footprintz = cfg.fpCor,
                explodeas = 'advancedFusionExplosion',
                selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = cfg.descCor:match('^(T%d [^-]+)'),
                    i18n_en_tooltip = cfg.descCor,
                    techlevel = tier,
                },
                weapondefs = wDefs,
                weapons = wList,
            })
            table.insert(newUnitNames, uName)
        end

        if unitDefs['legbastion'] then
            local uName = 'legbastiont' .. tier
            local base = unitDefs['legbastion']
            local wDefs, wList = {}, {}
            for idx, wInfo in ipairs(cfg.legWeapons) do
                local defKey = ('LEGBASTION_W%d_T%d'):format(idx, tier)
                wDefs[defKey] = tableMerge(defaultDef, wInfo.def)
                wList[idx] = { def = defKey, onlytargetcategory = wInfo.cat }
            end
            cloneUnit('legbastion', uName, {
                name = cfg.descLeg:match('^(T%d [^-]+)'),
                description = cfg.descLeg .. ' (large explosion)',
                metalcost = scaled(base.metalcost, cfg.costMult * 10),
                energycost = scaled(base.energycost, cfg.costMult * 10),
                buildtime = scaled(base.buildtime, cfg.costMult * 10),
                health = scaled(base.health, cfg.hpMult * 3),
                footprintx = cfg.fpLeg,
                footprintz = cfg.fpLeg,
                explodeas = 'advancedFusionExplosion',
                selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = cfg.descLeg:match('^(T%d [^-]+)'),
                    i18n_en_tooltip = cfg.descLeg,
                    techlevel = tier,
                },
                weapondefs = wDefs,
                weapons = wList,
            })
            table.insert(newUnitNames, uName)
        end
    end

    local builders = {
        'armack',
        'armaca',
        'armacv',
        'armt3airaide',
        'armt3aide',
        'corack',
        'coraca',
        'coracv',
        'cort3airaide',
        'cort3aide',
        'legack',
        'legaca',
        'legacv',
        'legt3airaide',
        'legt3aide',
    }

    for i = 3, 10 do
        builders[#builders + 1] = 'armcomlvl' .. i
        builders[#builders + 1] = 'corcomlvl' .. i
        builders[#builders + 1] = 'legcomlvl' .. i
    end

    for _, builderName in pairs(builders) do
        local faction = builderName:sub(1, 3)

        for _, newUnitName in ipairs(newUnitNames) do
            if (newUnitName:sub(1, 3)) == faction then
                ensureBuildOption(builderName, newUnitName)
            end
        end
    end
end
