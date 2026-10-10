# Raptor mini-boss specialists

Enable `raptorx-miniboss-specialists.lua` in the tweakdefs library, then Auto Pack
and copy the generated lobby commands. The pack is enabled by default and works
without the other RaptorX packs. Use a **Raptors** game: these are enemy wave
squads, not player-buildable units or replacements for the final queen.

| Boss | Anger unlock | HP | Signature skills |
| --- | ---: | ---: | --- |
| Ironhide Juggernaut | 35% | 180,000 | Repulsor claws, three-shot shockwave volley, 900 HP/s regeneration |
| Miremaw Plague Matriarch | 45% | 200,000 | Five-shot siege volley; 150-radius acid pools last 18 seconds; corrosive defensive spikes |
| Stormlock Tyrant | 55% | 240,000 | Six-shot lightning bursts, three-shot 280-AoE EMP volley; 8-second paralysis; EMP death explosion |
| Cindermaw Incinerator | 65% | 280,000 | Ten-shot breath volley; 100-radius burning ground lasts 8 seconds |
| Veilfang Stalker | 75% | 160,000 | Free moving cloak, radar stealth, fast movement, 8,000-damage claw strike; 250-distance proximity reveal |

Each registers its own `raptorcustomsquad = "1"` metadata in tweakdefs (clones do
not exist when tweakunits runs). Squads are special-rarity, weight 2, one unit
per selected squad, and eligible until 150% anger. Selection is random, not a
guaranteed scheduled spawn; multiple squads can coexist. No global boss limit
or custom decision-tree AI is claimed.

Native miniqueen models and `Raptors/raptor_miniqueen.cob` are retained. Slots
1 and 5 target ground; slots 2–4 retain their native defensive roles. Fire is
ground-only. Acid uses BAR's timed-area gadget and existing acid effects; fire
uses its fire-area effects and `burnthermite`. Area damage is subject to BAR's
stacking/shield rules and can affect units without the matching resistance,
including other Raptors. Miremaw and Cindermaw resist their own area types.
Stormlock can be EMP'd: inherited immunity is explicitly removed.

The Ultra Nightmare hardening pack excludes these specialists, preserving
their documented health, regeneration, cooldown windows and low spawn weights.
Existing units are not modified. Reapplying the pack does not multiply stats
or overwrite an already registered boss. Missing/incompatible bases are skipped.

## Verification

- `node --test tests/raptor-minibosses.test.js`: sources, squad progression,
  mechanics, library discovery, Base64 round-trip and the 16,384-character limit.
- With Lua 5.1+ installed: `lua tests/raptor-minibosses.lua`. Also run automatically
  by the Node test when `lua` is available; set `LUA` to another executable path.
  Checks deep-copy isolation, actual registration, weapon slots, cooldowns,
  hardening exclusion, repeated execution and absent/incompatible bases using
  representative native definition fixtures. It does not simulate Spring.
- In BAR: apply the packed commands to a Raptors lobby; verify wave eligibility
  at the five anger gates. Spawn each boss in a developer test match; confirm
  slot aiming, acid/fire persistence and effects, EMP recovery, knockback on
  mobile targets, regeneration, and cloak reveal/recloak. Confirm air units
  cannot be hit by ground-only weapons. Test with hardening both off and on.

Engine behavior and combat balance require the in-game checks; repository tests
alone cannot establish them.
