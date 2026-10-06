-- ArtilleryWalkersT4
-- Mobile Siege Artillery Walkers (Armada Intimidator Walker, Cortex Doomsday Artillery, Legion Bastion Walker)
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
        explosiongenerator = 'custom:genericshellexplosion-large-bomb',
        cegtag = '',
        soundhit = 'xplolrg3',
        soundstart = 'cannhvy2',
        rgbcolor = '1.0 0.5 0.2',
        rgbcolor2 = '1.0 0.8 0.4',
    }

    -- Armada Mobile Intimidator Walker
    if uDefs['armint'] or uDefs['armbanth'] then
        local src = uDefs['armbanth'] and 'armbanth' or 'armint'
        clone(src, 'armlrpcwalker', {
            name = 'T4 Intimidator Siege Walker',
            description = 'T4 Mobile LRPC Walker - 4500 Range Heavy Plasma Artillery (catastrophic explosion)',
            metalcost = 65000,
            energycost = 1400000,
            buildtime = 350000,
            health = 45000,
            speed = 22,
            footprintx = 7, footprintz = 7,
            movementclass = 'HKBOT7',
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Intimidator Siege Walker',
                i18n_en_tooltip = 'Deployable heavy plasma artillery walker with 4500 range',
                techlevel = 4,
            },
            weapondefs = {
                LRPC_WALKER_CANNON = tMerge(defaultDef, {
                    name = 'Intimidator Heavy Artillery', weapontype = 'Cannon', range = 4500, reloadtime = 6.0,
                    energypershot = 120000, accuracy = 400, damage = { default = 28000 }, areaofeffect = 350,
                    cratermult = 3.0, soundhit = 'xplolrg3', soundstart = 'cannhvy2', turret = true, weaponvelocity = 2200
                })
            },
            weapons = {
                [1] = { def = 'LRPC_WALKER_CANNON', onlytargetcategory = 'SURFACE' }
            }
        })
    end

    -- Cortex Mobile Doomsday Artillery
    if uDefs['corbuzz'] or uDefs['corgol'] then
        local src = uDefs['corgol'] and 'corgol' or 'corbuzz'
        clone(src, 'cormobiledoomsday', {
            name = 'T4 Doomsday Mobile Artillery',
            description = 'T4 Crawling Plasma Siege Mortar - 4200 Range Cluster Mortar (catastrophic explosion)',
            metalcost = 72000,
            energycost = 1500000,
            buildtime = 380000,
            health = 50000,
            speed = 20,
            footprintx = 8, footprintz = 8,
            movementclass = 'HTANK8',
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Doomsday Mobile Artillery',
                i18n_en_tooltip = 'Crawling heavy plasma mortar capable of relocating between waves',
                techlevel = 4,
            },
            weapondefs = {
                DOOMSDAY_MORTAR = tMerge(defaultDef, {
                    name = 'Doomsday Heavy Cluster Shell', weapontype = 'Cannon', range = 4200, reloadtime = 7.0,
                    energypershot = 130000, projectiles = 4, sprayangle = 800, damage = { default = 32000 },
                    areaofeffect = 400, cratermult = 3.0, soundhit = 'xplolrg3', soundstart = 'cannhvy1', turret = true, weaponvelocity = 2000
                })
            },
            weapons = {
                [1] = { def = 'DOOMSDAY_MORTAR', onlytargetcategory = 'SURFACE' }
            }
        })
    end

    -- Legion Mobile Bastion Siege Walker
    if uDefs['legbastion'] then
        clone('legbastion', 'legbastionwalker', {
            name = 'T4 Bastion Siege Walker',
            description = 'T4 Mobile Bastion Walker - 4000 Range Heat Ray & Shockwave Mortar (catastrophic explosion)',
            metalcost = 68000,
            energycost = 1450000,
            buildtime = 360000,
            health = 48000,
            speed = 24,
            footprintx = 7, footprintz = 7,
            movementclass = 'HKBOT7',
            explodeas = 'advancedFusionExplosion', selfdestructas = 'advancedFusionExplosion',
            customparams = {
                i18n_en_humanname = 'T4 Bastion Siege Walker',
                i18n_en_tooltip = 'Mobile heat-ray and shockwave mortar walker',
                techlevel = 4,
            },
            weapondefs = {
                BASTION_WALKER_RAY = tMerge(defaultDef, {
                    name = 'Mobile Bastion Heat Ray', weapontype = 'BeamLaser', largebeamlaser = true,
                    beamtime = 1.5, thickness = 8, range = 4000, reloadtime = 5.0, energypershot = 110000,
                    damage = { default = 30000 }, areaofeffect = 250, rgbcolor = '0.9 0.1 0.4',
                    soundhit = 'sizzle', soundstart = 'banthie2', turret = true, weaponvelocity = 2200
                })
            },
            weapons = {
                [1] = { def = 'BASTION_WALKER_RAY', onlytargetcategory = 'SURFACE' }
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

    local uNames = { 'armlrpcwalker', 'cormobiledoomsday', 'legbastionwalker' }
    for _, bName in pairs(builders) do
        local f = bName:sub(1, 3)
        for _, uName in ipairs(uNames) do
            if uName:sub(1, 3) == f then addOpt(bName, uName) end
        end
    end
end
