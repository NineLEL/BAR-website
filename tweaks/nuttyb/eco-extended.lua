-- ExtendedEco
-- Extended Eco (T4-T9 Fusion Reactors & Energy Converters)
-- Combines Tiers 4 through 9 into a single compact script to save slot space.
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

    local factions = { 'arm', 'cor', 'leg' }

    local function scaled(value, multiplier)
        return value and math.ceil(value * multiplier) or nil
    end

    local function round(value)
        return math.floor(value + 0.5)
    end

    local function cloneUnit(sourceUnit, targetUnit, overrides)
        if unitDefs[sourceUnit] and not unitDefs[targetUnit] then
            unitDefs[targetUnit] = tableMerge(unitDefs[sourceUnit], overrides)
        end
    end

    local tierConfigs = {
        [4] = {
            fusionEnergyMult = 1.5,
            fusionBuildtimeMult = 1.8,
            fusionStorageMult = 3.5,
            costMult = 1.8,
            healthMult = 5.0,
            convCapMult = 1.5,
            convEff = 0.021,
            explosion = 'ECO_EXPLOSION_T4',
            explosionDef = {
                name = 'T4 Eco Catastrophic Explosion', weapontype = 'Cannon',
                damage = { default = 15000 }, areaofeffect = 600, cratermult = 2.5,
                explosiongenerator = 'custom:fusionexplosion', cegtag = '',
                soundhit = 'xplolrg3', soundstart = '', rgbcolor = '1.0 0.8 0.2', rgbcolor2 = '1.0 1.0 0.8'
            },
            footprintConv = 6,
            footprintFus = 12,
        },
        [5] = {
            fusionEnergyMult = 3.0,
            fusionBuildtimeMult = 4.0,
            fusionStorageMult = 7.0,
            costMult = 4.0,
            healthMult = 10.0,
            convCapMult = 3.0,
            convEff = 0.0215,
            explosion = 'ECO_EXPLOSION_T5',
            explosionDef = {
                name = 'T5 Eco Catastrophic Explosion', weapontype = 'Cannon',
                damage = { default = 45000 }, areaofeffect = 900, cratermult = 3.0,
                explosiongenerator = 'custom:advancedfusionexplosion', cegtag = '',
                soundhit = 'xplolrg3', soundstart = '', rgbcolor = '1.0 0.8 0.2', rgbcolor2 = '1.0 1.0 0.8'
            },
            footprintConv = 6,
            footprintFus = 12,
        },
        [6] = {
            fusionEnergyMult = 6.0,
            fusionBuildtimeMult = 9.0,
            fusionStorageMult = 12.0,
            costMult = 9.0,
            healthMult = 22.0,
            convCapMult = 6.0,
            convEff = 0.022,
            explosion = 'ECO_EXPLOSION_T6',
            explosionDef = {
                name = 'T6 Eco Catastrophic Explosion', weapontype = 'Cannon',
                damage = { default = 120000 }, areaofeffect = 1300, cratermult = 3.5,
                explosiongenerator = 'custom:advancedfusionexplosion', cegtag = '',
                soundhit = 'xplolrg3', soundstart = '', rgbcolor = '1.0 0.8 0.2', rgbcolor2 = '1.0 1.0 0.8'
            },
            footprintConv = 6,
            footprintFus = 12,
        },
        [7] = {
            fusionEnergyMult = 12.0,
            fusionBuildtimeMult = 20.0,
            fusionStorageMult = 25.0,
            costMult = 20.0,
            healthMult = 50.0,
            convCapMult = 12.0,
            convEff = 0.022,
            explosion = 'ECO_EXPLOSION_T7',
            explosionDef = {
                name = 'T7 Eco Catastrophic Explosion', weapontype = 'Cannon',
                damage = { default = 300000 }, areaofeffect = 1800, cratermult = 4.0,
                explosiongenerator = 'custom:advancedfusionexplosion', cegtag = '',
                soundhit = 'xplolrg3', soundstart = '', rgbcolor = '1.0 0.8 0.2', rgbcolor2 = '1.0 1.0 0.8'
            },
            footprintConv = 8,
            footprintFus = 16,
        },
        [8] = {
            fusionEnergyMult = 24.0,
            fusionBuildtimeMult = 45.0,
            fusionStorageMult = 50.0,
            costMult = 45.0,
            healthMult = 110.0,
            convCapMult = 24.0,
            convEff = 0.022,
            explosion = 'ECO_EXPLOSION_T8',
            explosionDef = {
                name = 'T8 Eco Catastrophic Explosion', weapontype = 'Cannon',
                damage = { default = 750000 }, areaofeffect = 2400, cratermult = 5.0,
                explosiongenerator = 'custom:advancedfusionexplosion', cegtag = '',
                soundhit = 'xplolrg3', soundstart = '', rgbcolor = '1.0 0.8 0.2', rgbcolor2 = '1.0 1.0 0.8'
            },
            footprintConv = 8,
            footprintFus = 16,
        },
        [9] = {
            fusionEnergyMult = 48.0,
            fusionBuildtimeMult = 100.0,
            fusionStorageMult = 100.0,
            costMult = 100.0,
            healthMult = 250.0,
            convCapMult = 48.0,
            convEff = 0.022,
            explosion = 'ECO_EXPLOSION_T9',
            explosionDef = {
                name = 'T9 Eco Catastrophic Explosion', weapontype = 'Cannon',
                damage = { default = 1800000 }, areaofeffect = 3200, cratermult = 6.0,
                explosiongenerator = 'custom:advancedfusionexplosion', cegtag = '',
                soundhit = 'xplolrg3', soundstart = '', rgbcolor = '1.0 0.8 0.2', rgbcolor2 = '1.0 1.0 0.8'
            },
            footprintConv = 10,
            footprintFus = 20,
        },
    }

    local newUnitNames = {}

    for tier = 4, 9 do
        local cfg = tierConfigs[tier]

        for _, faction in ipairs(factions) do
            local isLegion = (faction == 'leg')

            local baseConverterName = isLegion and 'legadveconv'
                or (faction .. 'mmkr')
            local templateConverterName = baseConverterName .. 't3'
            local newConverterName = baseConverterName .. 't' .. tier
            local metalMakerDef = unitDefs[templateConverterName]

            if metalMakerDef then
                local capacity = scaled(
                    tonumber(metalMakerDef.customparams.energyconv_capacity)
                        or 0,
                    cfg.convCapMult
                )
                local efficiency = cfg.convEff
                cloneUnit(templateConverterName, newConverterName, {
                    name = ('T%d Energy Converter'):format(tier),
                    description = ('T%d Energy Converter'):format(tier),
                    metalcost = scaled(metalMakerDef.metalcost, cfg.costMult),
                    energycost = scaled(metalMakerDef.energycost, cfg.costMult),
                    buildtime = scaled(metalMakerDef.buildtime, cfg.costMult),
                    health = scaled(metalMakerDef.health, cfg.healthMult),
                    footprintx = cfg.footprintConv,
                    footprintz = cfg.footprintConv,
                    explodeas = cfg.explosion,
                    selfdestructas = cfg.explosion,
                    weapondefs = {
                        [cfg.explosion] = cfg.explosionDef,
                    },
                    customparams = {
                        energyconv_capacity = capacity,
                        energyconv_efficiency = efficiency,
                        i18n_en_humanname = ('T%d Energy Converter'):format(
                            tier
                        ),
                        i18n_en_tooltip = (
                            'Converts %d energy into %d metal per sec (extremely explosive)'
                        ):format(capacity, round(capacity * efficiency)),
                    },
                })

                table.insert(newUnitNames, newConverterName)
            end

            local baseFusionName = faction .. 'afus'
            local templateFusionName = baseFusionName .. 't3'
            local newFusionName = baseFusionName .. 't' .. tier
            local fusionDef = unitDefs[templateFusionName]

            if fusionDef then
                local energyMake = scaled(
                    fusionDef.energymake,
                    cfg.fusionEnergyMult
                ) or 0
                cloneUnit(templateFusionName, newFusionName, {
                    name = ('T%d Fusion Reactor'):format(tier),
                    description = ('T%d Fusion Reactor'):format(tier),
                    buildtime = scaled(
                        fusionDef.buildtime,
                        cfg.fusionBuildtimeMult
                    ),
                    metalcost = scaled(fusionDef.metalcost, cfg.costMult),
                    energycost = scaled(fusionDef.energycost, cfg.costMult),
                    energymake = energyMake,
                    energystorage = scaled(
                        fusionDef.energystorage,
                        cfg.fusionStorageMult
                    ),
                    health = scaled(fusionDef.health, cfg.healthMult),
                    idleautoheal = scaled(fusionDef.idleautoheal, tier * 15),
                    damagemodifier = 0.95,
                    footprintx = cfg.footprintFus,
                    footprintz = cfg.footprintFus,
                    explodeas = cfg.explosion,
                    selfdestructas = cfg.explosion,
                    weapondefs = {
                        [cfg.explosion] = cfg.explosionDef,
                    },
                    customparams = {
                        buildinggrounddecaldecayspeed = 30,
                        buildinggrounddecalsizex = cfg.footprintFus * 1.5,
                        buildinggrounddecalsizey = cfg.footprintFus * 1.5,
                        removestop = true,
                        removewait = true,
                        techlevel = 3,
                        unitgroup = 'energy',
                        usebuildinggrounddecal = true,
                        i18n_en_humanname = ('T%d Fusion Reactor'):format(tier),
                        i18n_en_tooltip = (
                            'Produces %d Energy (extremely explosive)'
                        ):format(energyMake),
                    },
                    sfxtypes = {
                        pieceexplosiongenerators = {
                            [1] = 'deathceg2',
                            [2] = 'deathceg3',
                            [3] = 'deathceg4',
                        },
                    },
                    sounds = {
                        canceldestruct = 'cancel2',
                        underattack = 'warning1',
                        count = {
                            'count6',
                            'count5',
                            'count4',
                            'count3',
                            'count2',
                            'count1',
                        },
                        select = {
                            'fusion2',
                        },
                    },
                })

                table.insert(newUnitNames, newFusionName)
            end

            -- 3. Metal Extractor (T4-T9)
            local baseMexName = isLegion and 'legmoho' or (faction .. 'moho')
            if not unitDefs[baseMexName] then baseMexName = faction .. 'mex' end
            local newMexName = faction .. 'mext' .. tier
            local mexDef = unitDefs[baseMexName]

            if mexDef then
                local metalExtracts = (mexDef.extractsmetal or 0.001) * cfg.fusionEnergyMult
                local metalMakes = (mexDef.makesmetal or 0) * cfg.fusionEnergyMult
                cloneUnit(baseMexName, newMexName, {
                    name = ('T%d Metal Extractor'):format(tier),
                    description = ('T%d Metal Extractor'):format(tier),
                    metalcost = scaled(mexDef.metalcost, cfg.costMult),
                    energycost = scaled(mexDef.energycost, cfg.costMult),
                    buildtime = scaled(mexDef.buildtime, cfg.costMult),
                    health = scaled(mexDef.health, cfg.healthMult),
                    extractsmetal = metalExtracts,
                    makesmetal = metalMakes,
                    explodeas = cfg.explosion,
                    selfdestructas = cfg.explosion,
                    weapondefs = {
                        [cfg.explosion] = cfg.explosionDef,
                    },
                    customparams = {
                        i18n_en_humanname = ('T%d Metal Extractor'):format(tier),
                        i18n_en_tooltip = ('High-capacity T%d Metal Extractor (extremely explosive)'):format(tier),
                        techlevel = tier,
                    },
                })
                table.insert(newUnitNames, newMexName)
            end

            -- 4. Geothermal Power Plant with Defense Turret (T4-T9)
            local baseGeoName = faction .. 'geo'
            if not unitDefs[baseGeoName] then baseGeoName = 'armgeo' end
            local newGeoName = faction .. 'geot' .. tier
            local geoDef = unitDefs[baseGeoName]

            if geoDef then
                local energyMakeGeo = scaled(geoDef.energymake or 1250, cfg.fusionEnergyMult) or 0
                cloneUnit(baseGeoName, newGeoName, {
                    name = ('T%d Geothermal Power Plant'):format(tier),
                    description = ('T%d Geothermal Power Plant'):format(tier),
                    metalcost = scaled(geoDef.metalcost, cfg.costMult),
                    energycost = scaled(geoDef.energycost, cfg.costMult),
                    buildtime = scaled(geoDef.buildtime, cfg.costMult),
                    health = scaled(geoDef.health, cfg.healthMult),
                    energymake = energyMakeGeo,
                    footprintx = cfg.footprintFus,
                    footprintz = cfg.footprintFus,
                    explodeas = cfg.explosion,
                    selfdestructas = cfg.explosion,
                    weapondefs = {
                        [cfg.explosion] = cfg.explosionDef,
                    },
                    weapons = {},
                    customparams = {
                        i18n_en_humanname = ('T%d Geothermal Power Plant'):format(tier),
                        i18n_en_tooltip = ('Produces %d Energy (extremely explosive)'):format(energyMakeGeo),
                        techlevel = tier,
                    },
                })
                table.insert(newUnitNames, newGeoName)
            end
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

    for _, builderName in pairs(builders) do
        local faction = builderName:sub(1, 3)

        for _, newUnitName in ipairs(newUnitNames) do
            if (newUnitName:sub(1, 3)) == faction then
                ensureBuildOption(builderName, newUnitName)
            end
        end
    end
end
