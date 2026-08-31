# WeaponSwingTimer - 3.3.5a (WotLK) Backport

A backport of **WeaponSwingTimer** to World of Warcraft **3.3.5a (Wrath of the Lich King)**.

> **All credit for this addon goes to [LeftHandedGlove](https://github.com/LeftHandedGlove).**
> I did not write this addon — I only adapted the existing Classic version so it runs on 3.3.5a clients.
>
> - Original project: <https://github.com/LeftHandedGlove/WeaponSwingTimerAddon>
> - Original addon page: <https://www.curseforge.com/wow/addons/weaponswingtimer>
>
> If you play retail or Classic, please use the original above — this repository is **only** for 3.3.5a.

---

## What it does

WeaponSwingTimer shows you when your next weapon swing or shot will land.

- **Melee bars** — tracks your main-hand and off-hand swing timers, plus your current target's.
- **Hunter / wand bars** — tracks Auto Shot and Shoot timing, and the cast time of shots such as Aimed Shot and Multi-Shot, so you can avoid clipping your next auto attack.
- Bars are movable by click-and-drag, and colours, size, text and transparency are all configurable.

Open the settings with any of:

```
/wst
/weaponswingtimer
/WeaponSwingTimer
```

Settings are saved per character.

## Installation

1. Download the `.zip` from the [Releases](../../releases) page.
2. Extract it into your `Interface\AddOns` folder.
3. Check if the result looks like this:

```
Interface\AddOns\WeaponSwingTimer
```

4. Restart the game, or type `/reload` if you are already logged in.

> **Don't use the green "Code → Download ZIP" button.** It produces a folder with `-main` on the end of the name, and WoW will not load an addon whose folder name doesn't match its `.toc`. Always download from **Releases**.

## What was changed for 3.3.5a

The 3.3.5 client is several expansions older than the one this addon was written for, and a number of API functions either don't exist yet or return their values in a different order. The changes were:

- **`.toc` interface version** set to `30300`.
- **Combat log** — `CombatLogGetCurrentEventInfo()` doesn't exist on 3.3.5, and the event's arguments use an older, shorter layout (`hideCaster` was added in 4.1, raid flags in 4.2). The payload is now re-slotted so the rest of the addon reads the correct fields.
- **Spellcast events** — `spellID` was only added to `UNIT_SPELLCAST_*` in 4.0.1, so 3.3.5 sends a spell *name* instead. The id is now resolved from the name.
- **`GetSpellInfo`** — returns a different set of values in 3.3.5 (and no spell id at all). Wrapped in a compatibility helper.
- **Texture paths** — switched to backslashes with an explicit `.blp` extension, which 3.3.5 requires for loose addon files.
- **`SetColorTexture`** (added in Legion) — polyfilled to the older `SetTexture(r, g, b, a)` form.
- **`SetObeyStepOnDrag`** — guarded, since it doesn't exist on 3.3.5.
- **Player GUID** — refreshed on `PLAYER_ENTERING_WORLD`, as it isn't reliably available at `ADDON_LOADED` on this client.
- **Saved settings** — checkbox values are stored as real booleans. On 3.3.5 `GetChecked()` returns `1`/`nil`, and storing `nil` deletes the key, which made unticked boxes reset to their defaults on every login.
- **Pixel alignment** — bar sizes are snapped to whole physical pixels to avoid a stray 1px line at certain width/height values.

## Known limitations

- **Off-hand swings are predicted, not measured.** The 3.3.5 combat log has no flag distinguishing main-hand from off-hand attacks, so a dual-wielded off-hand swing is attributed to whichever hand was due to swing. Main-hand tracking is exact; off-hand may drift slightly, particularly with weapons of very different speeds.
- Tested on 3.3.5a private servers. It is not intended for, and will not load on, retail or modern Classic clients.

## Bug reports

If something misbehaves, please open an [Issue](../../issues) and include:

- your class and what you were doing at the time,
- the exact error text if you have an error handler such as BugSack installed,
- your addon version (see `## Version` in the `.toc`).

Please report issues with **this backport** here, and not to the original author — the bugs are far more likely to be mine than his.

## Credits

- **[LeftHandedGlove](https://github.com/LeftHandedGlove)** — original author of WeaponSwingTimer. All of the original code, artwork and design are his.
- 3.3.5a backport by **Huge**.

This project is not affiliated with or endorsed by the original author, Blizzard Entertainment, or any server.
