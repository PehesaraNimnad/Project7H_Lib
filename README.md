# Project7H_Lib

One shared layer between your scripts and the rest of the server. Write a script once against `P7H.*` and it works on Qbox, QBCore, ESX, ox_core or ND, with whatever inventory, target, notify, fuel, keys, dispatch, banking, phone or clothing script the server runs.

- **Framework:** Qbox, QBCore, ESX, ox_core, ND
- **Inventory:** ox_inventory, qb, ps, qs, codem, core, tgiann, origen, ak47, jaksam, one, hex, S-Inventory, jpr
- **Target:** ox_target, qb-target, core_focus, ContextMenu, or text UI + key
- **Also:** notify, progress bar, text UI, fuel, car keys, dispatch, society / banking, boss menu, phone, appearance, weather, spawn, housing

Every supported script is listed in [`config.lua`](config.lua). Every function is listed in [`EXPORTS.md`](EXPORTS.md).

## Install

1. Download the latest release and put `Project7H_Lib` in your resources.
2. Start it **after** your framework and the scripts it talks to, and **before** the scripts that use it:
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure qbx_core
   ensure ox_inventory
   ensure Project7H_Lib
   ensure my_script
   ```
3. That's it. Every provider is `auto` and detects what is installed.

### Choosing a provider

`auto` takes the first matching resource that is **installed** (stopped resources count). When two of a kind are installed, for example `ox_fuel` in a disabled folder next to the fuel script you really use, pin the right one with a replicated convar in `server.cfg`. No need to edit the resource:

```cfg
setr p7h:framework qbox
setr p7h:inventory ox_inventory
setr p7h:target ox_target
setr p7h:notify ox_lib
setr p7h:fuel ox_fuel
setr p7h:carKeys qbx_vehiclekeys
setr p7h:dispatch ps-dispatch
```

The name is `p7h:` + the setting from `config.lua` in camelCase (`Config.CarKeys` → `p7h:carKeys`). The values each one accepts are listed above it in `config.lua`. `none` turns a kind off.

## Use it in a script

```lua
-- fxmanifest.lua
shared_scripts {
    '@ox_lib/init.lua',
    '@Project7H_Lib/imports.lua', -- sets the global P7H
}
dependencies { 'ox_lib', 'Project7H_Lib' }
```

```lua
-- server
local job   = P7H.Framework.GetPlayerJob(source)   -- { name, label, grade, grade_label, isboss, type, onduty }
local money = P7H.Framework.GetMoney(source)       -- { money, bank, black_money }
if money.bank >= 500 and P7H.Framework.RemoveMoney(source, 'bank', 500) then
    P7H.Inventory.AddItem(source, 'repairkit', 1)
    P7H.Notify.ShowNotify(source, 'Bought a repair kit', 'success')
end

-- client
P7H.Target.AddLocalEntity(ped, {
    { label = 'Talk', icon = 'fa-solid fa-comments', onSelect = function() print('hi') end },
})
P7H.TextUI.Show('[E] Open shop')
P7H.Fuel.SetFuel(vehicle, 100.0)
P7H.Dispatch.SendAlert({ code = '10-90', title = 'Store robbery', priority = 'high', job = 'police' })
```

Without `imports.lua`:

```lua
local P7H = exports['Project7H_Lib']:GetLib()
```

A kind is `nil` when nothing is installed for it (or it is set to `none`), so guard optional ones:

```lua
if P7H.Fuel then P7H.Fuel.SetFuel(vehicle, 100.0) end
```

## Events

| Event | Side | Arguments |
|---|---|---|
| `Project7H_Lib/server/playerLoaded` | server | `src` |
| `Project7H_Lib/server/playerUnloaded` | server | `src` |
| `Project7H_Lib/client/setPlayerData` | client | player data |
| `P7H.Framework.LoadedEvent` / `LoggedOutEvent` | client | net event names for the running framework |

## Adding a script

Each provider is one small file in `client/<kind>/` or `server/<kind>/`, named after the resource. Copy the closest one, change the resource name in its first line and fill in the functions. Functions that are not tied to one provider (character login, routing buckets, weather, spawn, housing, appearance preview, metadata, vehicle owner) live in `client/extras/` and `server/extras/`.

## Licence

GPL-3.0, see [`LICENSE`](LICENSE).
