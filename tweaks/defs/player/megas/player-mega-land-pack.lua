do
    local U, L, P, M = UnitDefs, string.lower, pairs, math.max
    local function C(t)
        if type(t) ~= "table" then
            return t
        end
        local r = {}
        for k, v in P(t) do
            r[C(k)] = C(v)
        end
        return r
    end
    local function teach(bld, dst)
        for b in bld:gmatch("%S+") do
            local u = U[b] or (UnitDefNames and UnitDefNames[b])
            if u then
                u.buildoptions = u.buildoptions or {}
                local h = false
                for _, x in ipairs(u.buildoptions) do
                    if x == dst then
                        h = true
                        break
                    end
                end
                if not h then
                    u.buildoptions[#u.buildoptions + 1] = dst
                end
            end
        end
    end
    local function fixW(t, k)
        -- Normalize required weapon fields without changing sound paths into tables.
        t.name = tostring(t.name or k or "UnknownWeapon")
        t.Name = t.name
        t.description = tostring(t.description or t.name)
        t.Description = t.description
        t.weapontype = t.weapontype or "Cannon"
        -- BAR scavenger weapondef_post.lua calls convertToPurple() on
        -- laser explosiongenerator without checking for nil.
        if t.weapontype == "BeamLaser" or t.weapontype == "LaserCannon" or t.weapontype == "DGun" then
            if type(t.explosiongenerator) ~= "string" or t.explosiongenerator == "" then
                t.explosiongenerator = "custom:genericshellexplosion-small"
            end
        end
        t.model = type(t.model) == "string" and t.model or ""
        t.Model = t.model
        local function sound(v, fallback)
            if type(v) == "table" then v = v[1] end
            if type(v) ~= "string" or v == "" then return fallback end
            return v
        end
        t.soundstart = sound(t.soundstart, "cannhvy5")
        t.soundhit = sound(t.soundhit, "xplomed1")
        t.soundhitdry = sound(t.soundhitdry, t.soundhit)
        t.damage = type(t.damage) == "table" and t.damage or { default = 0 }
        t.damage.default = t.damage.default or 0
        return t
    end

    local function install(u, k, w, cat)
        k = k:lower()
        u.weapondefs, u.weapons = u.weapondefs or {}, u.weapons or {}
        local ow, st = u.weapons, w.is_suite and w.slots or { [1] = w }
        u.weapons = {}
        for i, v in P(st) do
            local sk = w.is_suite and (k .. "_" .. i) or k
            v.noselfdamage, v.turret = true, true
            local cv = fixW(C(v), sk)
            u.weapondefs[string.lower(sk)] = cv
            local m = { def = string.lower(sk), onlytargetcategory = v.onlytargetcategory or cat or "SURFACE VTOL" }
            if ow[i] then
                for pk, pv in P(ow[i]) do
                    if
                        pk ~= "def"
                        and m[pk] == nil
                        and pk ~= "onlytargetcategory"
                        and pk ~= "maindir"
                        and pk ~= "maxangledif"
                    then
                        m[pk] = C(pv)
                    end
                end
            end
            u.weapons[i] = m
        end
        if #ow > #u.weapons then
            local dk = k .. "_d"
            u.weapondefs[dk] = fixW(
                {
                    weapontype = "Cannon",
                    range = 1,
                    reloadtime = 9999,
                    noselfdamage = true,
                    turret = true,
                    explosiongenerator = "custom:genericshellexplosion-tiny",
                },
                dk
            )
            for s = #u.weapons + 1, #ow do
                local sl = ow[s]
                local d = { def = dk, onlytargetcategory = "NONE", badtargetcategory = "ALL" }
                if sl then
                    d.maindir, d.maxangledif = sl.maindir, sl.maxangledif
                end
                u.weapons[s] = d
            end
        end
    end
    local function findSrc(c)
        for i = 1, #c do
            local s = U[c[i]] or U[L(c[i])] or (UnitDefNames and (UnitDefNames[c[i]] or UnitDefNames[L(c[i])]))
            if s then
                return s, c[i]
            end
        end
    end
    local LG, EA = "armshltx corgant leggant everyexpe", "armapt3 corapt3 legapt3 everyexpe"
    local function getAir()
        for b in EA:gmatch("%S+") do
            if U[b] or (UnitDefNames and UnitDefNames[b]) then
                return EA
            end
        end
        return "armaap coraap legaap"
    end
    local SC, SN, SM, SF, SR =
        "cannhvy5",
        "xplonuk4",
        "xplomed1",
        "flakfire",
        "rockhvy1"
    local CT, CF, CB, EF, EE, ES =
        "cruisemissiletrail-tacnuke",
        "flaktrailaamg",
        "flamestreamxl",
        "custom:starfire-explosion",
        "custom:juno-explo",
        "custom:genericshellexplosion-huge"
    local TS, TV, TSV = "SURFACE", "VTOL", "SURFACE VTOL"
    local function W(n, t, r, rel, v, aoe, e, d, s, c, vt, ex)
        local o = {
            name = n,
            weapontype = t,
            range = r,
            reloadtime = rel,
            weaponvelocity = v,
            areaofeffect = aoe,
            energypershot = e,
            damage = { default = d },
            soundstart = SC,
            soundhit = SM,
            soundhitdry = SM,
            model = "",
        }
        if s then
            o.damage.shields = s
        end
        if c then
            o.damage.commanders = c
        end
        if vt then
            o.damage.vtol = vt
        end
        if ex then
            for k, val in P(ex) do
                o[k] = val
            end
        end
        return fixW(o, n)
    end
    local WP = {
        jump = W(
            "Rift Cannon",
            "Cannon",
            2500,
            5,
            1800,
            350,
            6000,
            19500,
            24500,
            7500,
            nil,
            {
                accuracy = 180,
                size = 22,
                stages = 36,
                alpha = 0.9,
                intensity = 2.4,
                rgbcolor = "0 0.95 1",
                cegtag = "railgun-epic",
                explosiongenerator = EF,
                soundstart = "heavyrailgun",
                soundhit = "xplolrg4",
                craterboost = 5,
                cratermult = 3.5,
                impulsefactor = 12,
                impulseboost = 8,
                camerashake = 110,
                onlytargetcategory = TS,
            }
        ),
        crack = W(
            "Sabot Shotgun",
            "Cannon",
            2400,
            3.0,
            2400,
            240,
            12e3,
            5500,
            34e3,
            2200,
            nil,
            {
                projectilespershot = 8,
                burst = 2,
                burstrate = 0.08,
                sprayangle = 850,
                customparams = { shotgun = true },
                accuracy = 320,
                separation = 0.8,
                size = 10,
                stages = 24,
                intensity = 2.0,
                rgbcolor = "1 0.52 0.12",
                cegtag = "gausscannonprojectilexl",
                explosiongenerator = "custom:plasmahit-huge",
                soundstart = "sabotfire",
                soundhit = "sabothit",
                craterboost = 3,
                cratermult = 2,
                edgeeffectiveness = 0.85,
                onlytargetcategory = TS,
            }
        ),
        sol = W(
            "Cataclysm",
            "Cannon",
            3400,
            4.2,
            520,
            850,
            75e3,
            190e3,
            320e3,
            28e3,
            nil,
            {
                accuracy = 100,
                edgeeffectiveness = 0.85,
                burnblow = true,
                firestarter = 100,
                size = 44,
                stages = 48,
                intensity = 3.5,
                alpha = 0.95,
                rgbcolor = "1 0.48 0.04",
                cegtag = "starfire_arty",
                explosiongenerator = "custom:nukedatbewm",
                soundstart = "lrpcshot3",
                soundhit = SN,
                craterboost = 7,
                cratermult = 5,
                impulsefactor = 14,
                impulseboost = 9,
                camerashake = 180,
                onlytargetcategory = TS,
            }
        ),
        flak = W(
            "Flak Storm",
            "Cannon",
            1900,
            2.4,
            3200,
            160,
            500,
            60,
            180,
            nil,
            420,
            {
                canattackground = false,
                burnblow = true,
                burst = 6,
                burstrate = 0.12,
                projectiles = 4,
                sprayangle = 1800,
                edgeeffectiveness = 0.9,
                size = 8,
                rgbcolor = "1 0.5 0.12",
                cegtag = CF,
                explosiongenerator = "custom:flakshard",
                soundstart = SF,
                soundhit = "flakhit2",
                onlytargetcategory = TV,
            }
        ),
        tesla = W(
            "Tesla Battery",
            "LightningCannon",
            1150,
            2,
            4200,
            90,
            500,
            1600,
            450,
            120,
            nil,
            {
                burst = 4,
                burstrate = 0.1,
                customparams = { spark_forkdamage = 0.35, spark_range = 135, spark_maxunits = 2 },
                thickness = 14,
                laserflaresize = 8,
                rgbcolor = "0.22 0.88 1",
                cegtag = "lightning_stormbolt",
                explosiongenerator = "custom:genericshellexplosion-large-lightning-thor",
                soundstart = "electric2",
                soundhit = "xploelc2",
                soundhitdry = "lashit",
                edgeeffectiveness = 0.85,
                onlytargetcategory = TS,
            }
        ),
        pyro = W(
            "Carpet Mortar",
            "Cannon",
            1300,
            3.2,
            1100,
            140,
            600,
            1800,
            2200,
            350,
            nil,
            {
                burst = 8,
                burstrate = 0.1,
                sprayangle = 900,
                accuracy = 250,
                groundbounce = true,
                bouncerebound = 0.65,
                numbounce = 1,
                firestarter = 100,
                size = 8.5,
                stages = 22,
                intensity = 1.8,
                rgbcolor = "1 0.35 0.05",
                cegtag = CB,
                explosiongenerator = "custom:fire-incinerator",
                soundstart = "flamhvy1",
                soundhit = "flamhit1",
                edgeeffectiveness = 0.85,
                cratermult = 0.2,
                camerashake = 45,
                onlytargetcategory = TS,
            }
        ),
        tectonic = W(
            "Tectonic Shockwave",
            "Cannon",
            2300,
            5.5,
            520,
            360,
            4800,
            22000,
            26500,
            nil,
            nil,
            {
                accuracy = 160,
                impulsefactor = 3.0,
                size = 20,
                stages = 32,
                intensity = 2.8,
                alpha = 0.92,
                rgbcolor = "0.8 0.6 0.2",
                cegtag = "arty-extraheavy",
                explosiongenerator = EF,
                soundstart = "lrpcshot3",
                soundhit = SN,
                craterboost = 5,
                cratermult = 3.0,
                edgeeffectiveness = 0.85,
                camerashake = 100,
                onlytargetcategory = TS,
            }
        ),
        mirv = W(
            "Corrupted MIRV Cluster",
            "Cannon",
            1700,
            3.2,
            2400,
            160,
            1800,
            1100,
            1600,
            nil,
            480,
            {
                projectiles = 5,
                burst = 2,
                burstrate = 0.12,
                sprayangle = 700,
                separation = 0.6,
                accuracy = 240,
                size = 14,
                stages = 28,
                intensity = 2.2,
                rgbcolor = "1 0.4 0.6",
                cegtag = "gausscannonprojectilexl",
                explosiongenerator = "custom:genericshellexplosion-large-bomb",
                soundstart = "sabotfire",
                soundhit = "sabothit",
                craterboost = 3,
                cratermult = 2.0,
                edgeeffectiveness = 0.85,
                camerashake = 70,
                onlytargetcategory = TSV,
            }
        ),
        vortex = W(
            "Vortex Disintegrator",
            "BeamLaser",
            1850,
            2.5,
            4500,
            120,
            1600,
            7600,
            10500,
            nil,
            nil,
            {
                beamtime = 0.4,
                largebeamlaser = true,
                corethickness = 0.6,
                laserflaresize = 10,
                scrollspeed = 10,
                pulsespeed = 8,
                texture3 = "largebeam",
                tilelength = 150,
                thickness = 8,
                rgbcolor = "0 0.9 1",
                rgbcolor2 = "0.6 1 1",
                cegtag = "laserhit-large-aqua",
                explosiongenerator = "custom:laserhit-large-aqua",
                soundstart = "beamershot",
                soundhit = "burn02",
                edgeeffectiveness = 0.90,
                onlytargetcategory = TSV,
            }
        ),
                siege = W("Apollyon Siege Driver", "Cannon", 2450, 4, 1900, 180, 3500, 18000, 22000, 5000, nil, {
            accuracy = 120, size = 16, cegtag = "arty-extraheavy", explosiongenerator = ES,
            soundstart = "cannhvy6", soundhit = "xplolrg4", onlytargetcategory = TS,
        }),
        microflak = W("Apollyon Microflak", "Cannon", 1150, 2.4, 3100, 100, 450, 0, nil, nil, 750, {
            burst = 8, burstrate = 0.1, burnblow = true, canattackground = false,
            cegtag = CF, explosiongenerator = "custom:flakshard", soundstart = SF, onlytargetcategory = TV,
        }),
        rockets = W("Apollyon Tracking Battery", "MissileLauncher", 1250, 3.2, 1900, 65, 750, 1200, nil, nil, nil, {
            burst = 4, burstrate = 0.15, tracks = true, turnrate = 48e3, flighttime = 3,
            startvelocity = 700, weaponacceleration = 1200, cegtag = "missiletrailaa-large",
            explosiongenerator = ES, soundstart = "packolau", onlytargetcategory = TS,
        }),
        aegis = {
            name = "Apollyon Aegis Field", weapontype = "Shield",
            shield = {
                radius = 480, power = 65000, powerregen = 260, powerregenenergy = 150,
                startingpower = 65000, intercepttype = 1, smart = true, exterior = true,
                alpha = 0.34, goodcolor = "1 0.5 0.15 0.9", badcolor = "1 0.15 0.1 0.95", visible = true,
            },
        },
    }
    local function installApocalypse(u, src)
        local legion = src == "legapollyon"
        local active = legion and { [1] = "siege", [7] = "microflak", [9] = "rockets" }
            or { [1] = "siege", [4] = "microflak" }
        local stock = u.weapons or {}
        local count = M(#stock, legion and 10 or 5)
        u.weapons = {}
        u.weapondefs = u.weapondefs or {}
        u.weapondefs.apollyon_inert = {
            weapontype = "Cannon", range = 1, projectiles = 0, commandfire = true,
            canattackground = false, damage = { default = 0 }, customparams = { bogus = true },
        }
        for i = 1, count do
            local role = active[i]
            if role then
                local key, weapon = "apollyon_" .. role, C(WP[role])
                weapon.turret, weapon.noselfdamage = true, true
                u.weapondefs[key] = weapon
                local mount = stock[i] or {}
                u.weapons[i] = {
                    def = key, onlytargetcategory = weapon.onlytargetcategory,
                    maindir = mount.maindir, maxangledif = mount.maxangledif,
                    fastautoretargeting = mount.fastautoretargeting,
                }
            elseif not legion and i == 5 and stock[i] then
                u.weapons[i] = stock[i] -- Preserve the script's footstep effect.
            else
                u.weapons[i] = { def = "apollyon_inert", onlytargetcategory = "NONE" }
            end
        end
        u.weapondefs.apollyon_aegis = C(WP.aegis)
        u.weapons[count + 1] = { def = "apollyon_aegis" }
    end
local SP = {
        {
            "player_riftcolossus",
            { "armbanth" },
            "jump",
            WP.jump,
            "Void Leviathan",
            "Kinetic titan",
            { 75e3, 145e4, 270e3, 50, 3, 450, 0, 65 },
        },
        {
            "player_aegisbreaker",
            { "armrattet4", "corjugg", "armbanth" },
            "mirv",
            WP.mirv,
            "Titan Executor",
            "Cluster bombardier",
            { 68e3, 125e4, 220e3, 52, 3, 400, 0, 55 },
        },
        {
            "player_solardecimator",
            { "corjugg", "armbanth" },
            "tectonic",
            WP.tectonic,
            "Earthshaker Titan",
            "Shockwave titan",
            { 100e3, 205e4, 420e3, 38, 2, 600, 0, 100 },
        },
        {
            "player_skyfurnace",
            { "corkarganetht4", "corkarg" },
            "flak",
            WP.flak,
            "Inferno Citadel",
            "AA fortress",
            { 60e3, 110e4, 205e3, 46, 4, 350, 0, 50, 0, false, TV },
        },
        {
            "player_stormsovereign",
            { "armraz", "armbanth" },
            "tesla",
            WP.tesla,
            "Thunderlord Colossus",
            "Surface lightning walker; forks can hit nearby allies",
            { 60e3, 115e4, 195e3, 62, 4, 400, 0, 50 },
        },
        {
            "player_pyroclast",
            { "armmar", "armbanth" },
            "pyro",
            WP.pyro,
            "Magma Leviathan",
            "Area-denial walker with single-bounce mortar shells",
            { 60e3, 115e4, 230e3, 50, 4, 400, 0, 60 },
        },
        {
            "player_apollyonfortress",
            { "legapollyon", "corjugg" },
            "apollyon",
            installApocalypse,
            "Apocalypse Engine",
            "Mobile siege fortress with plasma shielding and independent close AA",
            { 100e3, 200e4, 330e3, 38, 3, 700, 0, 80 },
        },
        {
            "player_vortexdisintegrator",
            { "armbanth" },
            "vortex",
            WP.vortex,
            "Reality Render",
            "Beam control titan",
            { 78e3, 150e4, 245e3, 48, 2, 500, 0, 65 },
        },
    }
    local AB = getAir()
    for i = 1, #SP do
        local p = SP[i]
        local s, src = findSrc(p[2])
        if s and not U[p[1]] then
            local u = C(s)
            local st = p[7]
            local air = st[10]
            u.unitname, u.name, u.description = p[1], p[5], p[6]
            u.metalcost, u.energycost, u.buildtime = st[1], st[2], st[2]
            u.health, u.maxdamage = st[3], st[3]
            u.speed, u.maxthisunit, u.energyupkeep = st[4], st[5], st[6]
            u.energymake, u.autoheal = st[7] or 0, st[8] or 120
            u.sightdistance, u.radardistance = M(u.sightdistance or 0, 1100), M(u.radardistance or 0, 2600)
            u.activatewhenbuilt, u.builder, u.cantbetransported = true, false, true
            u.cancloak, u.cloakable, u.initcloaked = false, false, false
            u.radardistancejam = (st[9] and st[9] > 0) and st[9] or 0
            if air then
                u.canfly, u.hoverattack, u.airhoverfactor, u.cruisealt, u.turnrate, u.collide =
                    true, true, 0.15, 310, 480, true
                u.maxacc, u.maxdec = 0.08, 0.08
            else
                u.canfly, u.canhover, u.floater = false, false, false
                u.maxwaterdepth, u.upright = 48, true
            end
            u.customparams = u.customparams or {}
            u.customparams.techlevel, u.customparams.unitgroup = 4, "weapon"
            u.customparams.i18n_en_humanname, u.customparams.i18n_en_tooltip = p[5], p[6]
            if type(p[4]) == "function" then
                p[4](u, src)
            else
                install(u, p[3], p[4], st[11])
            end
            if p[1] == "player_pyroclast" then u.customparams.maxrange = nil end
            U[p[1]] = u
            if UnitDefNames then
                UnitDefNames[p[1]] = u
            end
            teach(air and AB or LG, p[1])
        end
    end
end
