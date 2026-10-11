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
        t.soundstart = sound(t.soundstart, "weapons/cannon_heavy.wav")
        t.soundhit = sound(t.soundhit, "weapons/xplomed1.wav")
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
                        and (w.is_suite or (pk ~= "maindir" and pk ~= "maxangledif"))
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
        "weapons/cannon_heavy.wav",
        "weapons/xplonuk4.wav",
        "weapons/xplomed1.wav",
        "weapons/flak_fire.wav",
        "weapons/rockhvy1.wav"
    local CT, CF, CB, EF, EE, ES =
        "cruisemissiletrail-tacnuke",
        "flakshard",
        "burnflame",
        "custom:FLASHNUKE280",
        "custom:exp_emp_large",
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
            o.damage.commandertoo = c
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
            3200,
            4.2,
            1800,
            650,
            48e3,
            28e3,
            42e3,
            8e3,
            nil,
            {
                accuracy = 180,
                size = 22,
                stages = 36,
                alpha = 0.9,
                intensity = 2,
                rgbcolor = "0 0.95 1",
                cegtag = CT,
                explosiongenerator = EF,
                soundstart = SC,
                soundhit = SM,
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
            3.2,
            2400,
            240,
            28e3,
            9600,
            38e3,
            3500,
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
                rgbcolor = "1 0.5 0.1",
                cegtag = "volcano_rock_trail",
                explosiongenerator = "custom:genericshellexplosion-medium",
                soundstart = SC,
                soundhit = SM,
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
            5.5,
            520,
            850,
            95e3,
            48e3,
            11e4,
            14e3,
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
                rgbcolor = "1 0.45 0.02",
                cegtag = CB,
                explosiongenerator = "custom:FLASHNUKE480",
                soundstart = SC,
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
            2400,
            1.8,
            3200,
            320,
            800,
            600,
            3200,
            nil,
            9800,
            {
                canattackground = false,
                burnblow = true,
                burst = 6,
                burstrate = 0.12,
                projectilespershot = 4,
                sprayangle = 1800,
                edgeeffectiveness = 0.9,
                size = 8,
                rgbcolor = "1 0.45 0.1",
                cegtag = CF,
                explosiongenerator = "custom:flakshard",
                soundstart = SF,
                soundhit = SF,
                onlytargetcategory = TV,
            }
        ),
        tesla = W(
            "Tesla Battery",
            "LightningCannon",
            1800,
            1.2,
            4200,
            140,
            650,
            1600,
            1800,
            550,
            4200,
            {
                projectilespershot = 4,
                burst = 10,
                burstrate = 0.08,
                sprayangle = 2000,
                thickness = 12,
                rgbcolor = "0.2 0.85 1",
                explosiongenerator = "custom:genericshellexplosion-small-lightning",
                soundstart = "weapons/tecl_fire.wav",
                soundhit = "weapons/lashit.wav",
                edgeeffectiveness = 0.85,
                onlytargetcategory = TSV,
            }
        ),
        pyro = W(
            "Carpet Mortar",
            "Cannon",
            2400,
            3.6,
            1100,
            260,
            750,
            5200,
            16e3,
            1200,
            nil,
            {
                burst = 20,
                burstrate = 0.05,
                sprayangle = 1600,
                accuracy = 400,
                groundbounce = true,
                bouncerebound = 0.65,
                bounceminspeed = 200,
                numsubcatches = 3,
                firestarter = 100,
                size = 8.5,
                stages = 22,
                rgbcolor = "1 0.35 0.05",
                cegtag = CB,
                explosiongenerator = "custom:napalm_fire",
                soundstart = SC,
                soundhit = "weapons/xplomed2.wav",
                edgeeffectiveness = 0.85,
                cratermult = 0.2,
                camerashake = 45,
                onlytargetcategory = TS,
            }
        ),
        apol_suite = {
            is_suite = true,
            slots = {
                [1] = W(
                    "Apollyon Siege Driver",
                    "Cannon",
                    2800,
                    3.8,
                    1900,
                    380,
                    14e3,
                    18500,
                    32e3,
                    3200,
                    nil,
                    {
                        accuracy = 180,
                        size = 16,
                        stages = 24,
                        rgbcolor = "1 0.35 0.05",
                        cegtag = "arty-large",
                        explosiongenerator = ES,
                        soundstart = SC,
                        soundhit = SM,
                        craterboost = 4,
                        cratermult = 2.5,
                        camerashake = 80,
                        onlytargetcategory = TS,
                    }
                ),
                [2] = W(
                    "Apollyon Siege Driver",
                    "Cannon",
                    2800,
                    3.8,
                    1900,
                    380,
                    14e3,
                    18500,
                    32e3,
                    3200,
                    nil,
                    {
                        accuracy = 180,
                        size = 16,
                        stages = 24,
                        rgbcolor = "1 0.35 0.05",
                        cegtag = "arty-large",
                        explosiongenerator = ES,
                        soundstart = SC,
                        soundhit = SM,
                        craterboost = 4,
                        cratermult = 2.5,
                        camerashake = 80,
                        onlytargetcategory = TS,
                    }
                ),
                [3] = W(
                    "Apollyon Shredder Array",
                    "Cannon",
                    2000,
                    1.2,
                    3400,
                    120,
                    420,
                    1450,
                    2800,
                    350,
                    2400,
                    {
                        burst = 30,
                        burstrate = 0.025,
                        sprayangle = 750,
                        accuracy = 280,
                        size = 5.5,
                        stages = 16,
                        rgbcolor = "1 0.85 0.2",
                        cegtag = CF,
                        explosiongenerator = "custom:genericshellexplosion-small",
                        soundstart = SF,
                        soundhit = "weapons/xplosml2.wav",
                        onlytargetcategory = TSV,
                    }
                ),
                [4] = W(
                    "Apollyon Skyfall VLS",
                    "MissileLauncher",
                    2400,
                    2.2,
                    3600,
                    140,
                    1800,
                    1200,
                    3200,
                    nil,
                    9200,
                    {
                        burst = 12,
                        burstrate = 0.06,
                        sprayangle = 500,
                        startvelocity = 1200,
                        weaponacceleration = 1900,
                        flighttime = 5.5,
                        tracks = true,
                        turnrate = 90e3,
                        dance = 6,
                        wobble = 110,
                        cegtag = "missiletrailaa",
                        explosiongenerator = "custom:genericshellexplosion-medium-aa",
                        soundstart = SR,
                        soundhit = "weapons/xplomed2.wav",
                        onlytargetcategory = TV,
                    }
                ),
                [5] = W(
                    "Apollyon Tachyon Lance",
                    "BeamLaser",
                    2200,
                    2.5,
                    4500,
                    40,
                    6400,
                    9800,
                    18e3,
                    1500,
                    nil,
                    {
                        beamtime = 0.4,
                        thickness = 8.5,
                        corethickness = 0.45,
                        laserflaresize = 12,
                        largebeamlaser = true,
                        explosiongenerator = "custom:genericshellexplosion-small",
                        rgbcolor = "1 0.15 0.15",
                        soundstart = "weapons/annigun1.wav",
                        soundhit = "weapons/burn02.wav",
                        onlytargetcategory = TS,
                    }
                ),
                [6] = fixW(
                    {
                        weapontype = "Shield",
                        shieldradius = 480,
                        shieldpower = 160e3,
                        shieldpowerregen = 1200,
                        shieldpowerregenenergy = 260,
                        shieldrepulser = true,
                        shieldintercepttype = 1,
                        shieldalpha = 0.28,
                        rgbcolor = "0.9 0.4 0.1",
                        visibleshield = true,
                    },
                    "Apollyon Aegis Field"
                ),
            },
        },
    }
    local SP = {
        {
            "player_riftcolossus",
            { "armbanth" },
            "jump",
            WP.jump,
            "Rift Colossus",
            "Kinetic titan",
            { 145e3, 32e5, 34e4, 56, 3, 2200, 0, 240 },
        },
        {
            "player_aegisbreaker",
            { "armrattet4", "corjugg", "armbanth" },
            "crack",
            WP.crack,
            "Aegis Breaker",
            "Shotgun titan",
            { 135e3, 28e5, 29e4, 52, 3, 2000, 0, 200 },
        },
        {
            "player_solardecimator",
            { "corjugg", "armbanth" },
            "sol",
            WP.sol,
            "Sol Decimator",
            "Solar titan",
            { 185e3, 44e5, 42e4, 38, 2, 2800, 6800, 360 },
        },
        {
            "player_skyfurnace",
            { "corkarganetht4", "corkarg" },
            "flak",
            WP.flak,
            "Sky Furnace",
            "AA fortress",
            { 120e3, 24e5, 26e4, 54, 4, 1800, 0, 180, 0, false, TV },
        },
        {
            "player_stormsovereign",
            { "armraz", "armbanth" },
            "tesla",
            WP.tesla,
            "Storm Sovereign",
            "Tesla walker",
            { 125e3, 26e5, 27e4, 62, 4, 1900, 0, 200 },
        },
        {
            "player_pyroclast",
            { "armmar", "armbanth" },
            "pyro",
            WP.pyro,
            "Pyroclast Dreadnought",
            "Fire titan",
            { 130e3, 27e5, 28e4, 50, 4, 2000, 0, 200 },
        },
        {
            "player_apollyonfortress",
            { "legapollyon", "corpun", "corint" },
            "apollyon",
            WP.apol_suite,
            "Apollyon Fortress",
            "Heavy artillery fortress",
            { 155e3, 34e5, 36e4, 42, 3, 2400, 0, 260 },
        },
    }
    local AB = getAir()
    for i = 1, #SP do
        local p = SP[i]
        local s = findSrc(p[2])
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
            install(u, p[3], p[4], st[11])
            U[p[1]] = u
            if UnitDefNames then
                UnitDefNames[p[1]] = u
            end
            teach(air and AB or LG, p[1])
        end
    end
end
