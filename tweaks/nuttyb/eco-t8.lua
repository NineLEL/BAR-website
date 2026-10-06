-- T8Eco
-- T8 Eco (Fusion Reactors & Energy Converters)
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

    local newUnitNames = {}

    for _, faction in ipairs(factions) do
        local isLegion = (faction == 'leg')

        local baseConverterName = isLegion and 'legadveconv'
            or (faction .. 'mmkr')
        local templateConverterName = baseConverterName .. 't3'
        local newConverterName = baseConverterName .. 't8'
        local metalMakerDef = unitDefs[templateConverterName]

        if metalMakerDef then
            local t8CostMult = 32.0
            local capacity = scaled(
                tonumber(metalMakerDef.customparams.energyconv_capacity) or 0,
                24.0
            )
            local efficiency = 0.023
            cloneUnit(templateConverterName, newConverterName, {
                name = 'T8 Energy Converter',
                description = 'T8 Energy Converter',
                metalcost = scaled(metalMakerDef.metalcost, t8CostMult),
                energycost = scaled(metalMakerDef.energycost, t8CostMult),
                buildtime = scaled(metalMakerDef.buildtime, t8CostMult),
                health = scaled(metalMakerDef.health, t8CostMult * 2.5),
                footprintx = 8,
                footprintz = 8,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    energyconv_capacity = capacity,
                    energyconv_efficiency = efficiency,
                    i18n_en_humanname = 'T8 Energy Converter',
                    i18n_en_tooltip = ('Converts %d energy into %d metal per sec (extremely explosive)'):format(
                        capacity,
                        round(capacity * efficiency)
                    ),
                },
            })

            table.insert(newUnitNames, newConverterName)
        end

        local baseFusionName = faction .. 'afus'
        local templateFusionName = baseFusionName .. 't3'
        local newFusionName = baseFusionName .. 't8'
        local fusionDef = unitDefs[templateFusionName]

        if fusionDef then
            local energyMake = scaled(fusionDef.energymake, 24.0) or 0
            cloneUnit(templateFusionName, newFusionName, {
                name = 'T8 Fusion Reactor',
                description = 'T8 Fusion Reactor',
                buildtime = scaled(fusionDef.buildtime, 32.0),
                metalcost = scaled(fusionDef.metalcost, 32.0),
                energycost = scaled(fusionDef.energycost, 32.0),
                energymake = energyMake,
                energystorage = scaled(fusionDef.energystorage, 80.0),
                health = scaled(fusionDef.health, 75.0 * 2.5),
                idleautoheal = scaled(fusionDef.idleautoheal, 80),
                damagemodifier = 0.95,
                footprintx = 16,
                footprintz = 16,
            explodeas = 'advancedFusionExplosion',
            selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    buildinggrounddecaldecayspeed = 30,
                    buildinggrounddecalsizex = 24,
                    buildinggrounddecalsizey = 24,
                    removestop = true,
                    removewait = true,
                    techlevel = 3,
                    unitgroup = 'energy',
                    usebuildinggrounddecal = true,
                    i18n_en_humanname = 'T8 Fusion Reactor',
                    i18n_en_tooltip = ('Produces %d Energy (extremely explosive)'):format(
                        energyMake
                    ),
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
