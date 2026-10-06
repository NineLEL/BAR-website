-- ExtendedBuilders
-- Extended Construction Turrets (T4-T5 Construction Turrets)
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

    local function cloneUnit(sourceUnit, targetUnit, overrides)
        if unitDefs[sourceUnit] and not unitDefs[targetUnit] then
            unitDefs[targetUnit] = tableMerge(unitDefs[sourceUnit], overrides)
        end
    end

    local tierConfigs = {
        [4] = {
            costMult = 3.0,
            healthMult = 2.5,
            workertime = 3200,
            builddistance = 500,
            explosion = 'fusionExplosion',
            tooltip = 'High buildpower (catastrophic explosion)',
        },
        [5] = {
            costMult = 8.0,
            healthMult = 6.0,
            workertime = 7500,
            builddistance = 400,
            explosion = 'advancedFusionExplosion',
            tooltip = 'Ultimate buildpower (catastrophic explosion)',
        },
    }

    local newUnitNames = {}

    for tier = 4, 5 do
        local cfg = tierConfigs[tier]

        for _, faction in ipairs(factions) do
            local templateTurretName = faction .. 'nanotct3'
            local newTurretName = faction .. 'nanotct' .. tier
            local turretDef = unitDefs[templateTurretName]

            if turretDef then
                cloneUnit(templateTurretName, newTurretName, {
                    name = ('T%d Construction Turret'):format(tier),
                    description = ('T%d Construction Turret'):format(tier),
                    metalcost = scaled(turretDef.metalcost, cfg.costMult),
                    energycost = scaled(turretDef.energycost, cfg.costMult),
                    buildtime = scaled(turretDef.buildtime, cfg.costMult),
                    health = scaled(turretDef.health, cfg.healthMult),
                    workertime = cfg.workertime,
                    builddistance = cfg.builddistance,
                    footprintx = 6,
                    footprintz = 6,
                    explodeas = cfg.explosion,
                    selfdestructas = cfg.explosion,
                    customparams = {
                        i18n_en_humanname = ('T%d Construction Turret'):format(
                            tier
                        ),
                        i18n_en_tooltip = cfg.tooltip,
                    },
                })

                table.insert(newUnitNames, newTurretName)
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
