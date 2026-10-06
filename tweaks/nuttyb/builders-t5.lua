-- T5Builders
-- T5 Construction Turrets
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

    local newUnitNames = {}

    for _, faction in ipairs(factions) do
        local templateTurretName = faction .. 'nanotct3'
        local newTurretName = faction .. 'nanotct5'
        local turretDef = unitDefs[templateTurretName]

        if turretDef then
            cloneUnit(templateTurretName, newTurretName, {
                name = 'T5 Construction Turret',
                description = 'T5 Construction Turret',
                metalcost = scaled(turretDef.metalcost, 8.0),
                energycost = scaled(turretDef.energycost, 8.0),
                buildtime = scaled(turretDef.buildtime, 8.0),
                health = scaled(turretDef.health, 6.0),
                workertime = 7500,
                builddistance = 400,
                footprintx = 6,
                footprintz = 6,
                explodeas = 'advancedFusionExplosion',
                selfdestructas = 'advancedFusionExplosion',
                customparams = {
                    i18n_en_humanname = 'T5 Construction Turret',
                    i18n_en_tooltip = 'Ultimate buildpower (catastrophic explosion)',
                },
            })

            table.insert(newUnitNames, newTurretName)
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
