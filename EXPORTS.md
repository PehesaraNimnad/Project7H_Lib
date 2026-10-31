# Project7H_Lib exports

Load the Lib once per script, then call everything on `P7H`:

```lua
shared_scripts { '@ox_lib/init.lua', '@Project7H_Lib/imports.lua' }   -- P7H = exports['Project7H_Lib']:GetLib()
dependencies { 'ox_lib', 'Project7H_Lib' }
```

| Export | Side | Returns |
|---|---|---|
| `exports['Project7H_Lib']:GetLib()` | client + server | the `P7H` table below |

`src` is a server id. `uniqueId` / `citizenid` is the character id (`citizenid` on Qbox / QBCore, `identifier` on ESX). A kind (e.g. `P7H.Fuel`) is `nil` when its config is `none` or no supported script is found, so check it before calling: `if P7H.Fuel then ... end`.

---

## Framework — server

| Function | Returns / notes |
|---|---|
| `P7H.Framework.Name` | `'qbox'`, `'qb'`, `'esx'`, `'ox'` or `'nd'` |
| `GetUniqueId(src)` | character id |
| `GetPlayerId(uniqueId)` | server id when online, else `nil` |
| `GetPlayerById(src)` / `GetPlayerByUniqueId(uniqueId)` | framework player object |
| `GetOfflinePlayerByCitizenId(citizenid)` / `GetOfflinePlayerByUniqueId(id)` | database row of an offline character |
| `IsLoaded(src)` | `true` when a character is loaded |
| `GetPlayerName(src, separate?)` | `'First Last'`, or `first, last` with `separate = true` |
| `GetPlayerDob(src)` / `GetPlayerGender(src)` | birth date / `'male'` or `'female'` |
| `GetPhone(src)` | phone number string |
| `GetPlayerJob(src)` | `{ name, label, grade, grade_name, grade_label, isboss, type, onduty }` |
| `SetJob(src, job, grade)` / `SetOfflineJob(uniqueId, job, grade)` | set a job |
| `CheckJobDuty(src)` / `SetJobDuty(src, onDuty)` | duty state |
| `GetJobs()` / `GetJobLabels()` / `GetJobList()` | all jobs / `{ [name] = label }` / sorted `{ name, label }` list |
| `GetGang(src)` | `label, name`, or `nil` without a gang |
| `GetMoney(src)` | `{ money, bank, black_money }` |
| `AddMoney(src, account, amount)` / `RemoveMoney(src, account, amount)` | account `'money'` or `'cash'`, `'bank'`, `'black_money'`; returns `true` / `false` (RemoveMoney does not check the balance: read `GetMoney` first) |
| `GetPlayerMetadata(srcOrCitizenid, key?)` / `SetPlayerMetadata(src, key, value)` | one value, or the whole table without `key` (offline characters too) |
| `CheckPlayerLicense(src, license)` / `AddPlayerLicense` / `RemovePlayerLicense` | licences in metadata |
| `CheckPermissions(src, groups)` / `GetPermission(src)` / `IsAdmin(src)` | in one of the groups / the player's `permission` field / admin check |
| `RegisterItem(name, fn)` | usable item (ox_inventory items use their own `server.export`) |
| `GetForensics(src)` | evidence data |
| `GetOnlinePlayers()` | list of server ids with a loaded character |
| `OnlineByCitizen()` | `{ [citizenid] = src }` |
| `Login(src, citizenid, newData?)` / `Logout(src)` / `DeleteCharacter(citizenid)` | multicharacter |
| `SetBucket(src, bucket)` / `GetPosition(src)` | routing bucket / saved `vec4` position |
| `GetOwnedVehicle(plate)` / `GetVehicleByPlate(plate)` / `SetVehicleImpounded(plate, state)` | owned vehicle row |
| `GetVehicleOwner(plate)` | citizenid of the owner (plate trimmed + upper case) |
| `GetPlayerVehicles(src)` | `{ { plate, model } }` |
| `GetPlayerObject(src)` / `GetOfflinePlayerObject(citizenid)` | framework player object (`PlayerData`), online / offline |
| `GetJobMembers(job)` | `{ { citizenid, grade } }` of every character with the job |
| `GetRawJob(src)` | the framework job table as is (`grade = { level, name, isboss }`, `payment`, `onduty`) |
| `GetPlayerObjects()` | `{ [src] = player object }` of everyone online |
| `GetPlayerObjectByCitizen(srcOrCitizenid)` / `GetPlayerDataOf(srcOrCitizenid)` | online first, else the offline character |
| `GetCharInfo(srcOrCitizenid, key?)` / `GetCharacterName(srcOrCitizenid)` | charinfo / `'First Last'` (offline too) |
| `GetJobGrade(job, grade)` | grade table from the shared jobs |
| `CountOnDuty(jobName)` / `CountOnDuty(jobType, true)` | on-duty count by job name / job type |

## Framework — client

| Function | Returns / notes |
|---|---|
| `P7H.Framework.IsPlayerLoaded()` | `true` when a character is loaded |
| `GetIdentifier()` | own character id |
| `GetPlayerName()` | own `'First Last'` |
| `GetPlayerData()` | raw player data (Qbox / QBCore) |
| `FetchPlayerJob()` | `{ name, label, grade }` |
| `CheckJobDuty()` | own duty state |
| `IsDead()` / `IsJailed()` | from metadata |
| `LoadedEvent` / `LoggedOutEvent` | net event names to `RegisterNetEvent` for load / logout |
| `TriggerPlayerLoaded()` | fires the framework load events (multicharacter) |

## Inventory

| Server | Client |
|---|---|
| `P7H.Inventory.AddItem(src, item, count, metadata?, slot?)` → `true` / `false` | `P7H.Inventory.GetItemCount(item, metadata?)` |
| `RemoveItem(src, item, count, metadata?, slot?)` → `true` / `false` | `GetItemsByName(item)` → `{ { slot, count, metadata } }` |
| `GetItemCount(src, item, metadata?)` | `GetPlayerItems()` |
| `CanCarryItem(src, item, count, metadata?)` | `GetItemData(item)` |
| `GetItemsByName(src, item)` → `{ { slot, count, metadata } }` | `OpenInventory(type, data)` |
| `GetItemSlot(src, slot)` / `SetMetadata(src, slot, metadata)` | `GetCurrentWeapon()` / `Disarm(state)` |
| `GetPlayerItems(src)` / `GetItemData(item)` | |
| `RegisterStash(id, label, slots, weight)` / `AddItemToStash(id, item, count, metadata?)` | |
| `GetInventory(id)` / `ClearInventory(id)` | |
| `CreateShop(name, data)` / `CustomDrop(prefix, items, coords)` / `RegisterHook(event, cb, options)` | |

## Notify

| Server | Client |
|---|---|
| `P7H.Notify.ShowNotify(src, message, type)` | `P7H.Notify.ShowNotify(message, type)` |

`type`: `'inform'`, `'success'`, `'error'`, `'warning'`.

## Target (client)

`AddGlobal(options)` / `RemoveGlobal(names)`, `AddPlayer` / `RemovePlayer`, `AddVehicle(options)` / `RemoveVehicle(names)`, `AddModel(models, options)` / `RemoveModel(models, names)`, `AddEntity(netIds, options)` / `RemoveEntity`, `AddLocalEntity(entities, options)` / `RemoveLocalEntity(entities, names)`, `AddSphereZone({ coords, radius, options })` → id / `RemoveSphereZone(id)`, `ToggleTarget(state)`.
Options use the ox_target format (`name`, `label`, `icon`, `distance`, `canInteract`, `onSelect`). Targets are removed automatically when the calling resource stops.

## Text UI and progress (client)

| Function | Notes |
|---|---|
| `P7H.TextUI.Show(text, options?)` / `P7H.TextUI.Hide()` | options as in `lib.showTextUI` |
| `P7H.Progress.Start(data)` / `StartCircle(data)` | `{ duration, label, canCancel, useWhileDead, anim, prop, disable }` → `true` when finished |
| `P7H.Progress.IsActive()` / `Cancel()` | |

## Fuel and car keys (client)

| Function | Notes |
|---|---|
| `P7H.Fuel.SetFuel(vehicle, level)` / `GetFuel(vehicle)` | level 0-100 |
| `P7H.CarKeys.CreateKeys(plate, vehicle?)` / `RemoveKeys(plate)` / `HasKey(plate)` | |

Server: `P7H.ServerKeys.Give(src, vehicle, plate?)` gives keys right after a server spawn (Project07_CarKeys, qbx_vehiclekeys, qb-vehiclekeys, wasabi_carlock), `P7H.ServerKeys.SetLocked(vehicle, locked)`.

## Dispatch

| Side | Function |
|---|---|
| client | `P7H.Dispatch.SendAlert({ code, title, icon, priority, job, blip = { sprite, scale, color }, time, coords? })` (adds coords + street) |
| server | `P7H.Dispatch.SendAlert(src, data)`, same data |

## Society and boss menu

| Function | Side |
|---|---|
| `P7H.Society.AddMoney(src, job, amount)` / `RemoveMoney(src, job, amount)` / `GetMoney(src, job)` | server (`src` may be `nil` on most banking scripts) |
| `P7H.BossMenu.OpenMenu()` | client |

## Phone

`P7H.Phone.Name` is the phone in use. Full API with `sd-phone`; the other phones only have `ToggleDisabled` on the client.

| Client | Notes |
|---|---|
| `ToggleDisabled(state)` / `IsDisabled()` | block the phone (cuffed, dead, in a menu) |
| `IsOpen()` / `IsLocked()` / `Open()` / `Close()` | |
| `OpenApp(appId, link?)` | `true` when opened |
| `Notify({ title, body?, app?, image?, appId? })` | phone banner |
| `HasService(capability?)` / `GetServiceBars()` | `'text'`, `'call'`, `'data'` / 0-4 |
| `IsOnWifi()` / `GetWifi()` / `IsBluetoothConnected(deviceId)` | |
| `AddCustomApp({ identifier, name, ui, job? })` / `RemoveCustomApp(id)` / `SendCustomAppMessage(id, { action, data })` | custom apps |
| `ShowWidget(appId, widgetId, data, onAction?)` / `HideWidget(appId, widgetId)` | lock screen cards |
| `GetActiveGroup()` | |

| Server | Notes |
|---|---|
| `GetNumber(src)` / `GetNumberByIdentifier(citizenid)` | phone number |
| `GetIdentifierByNumber(number)` / `GetSourceByNumber(number)` | reverse lookup |
| `HasPhone(src)` / `HasService(src, capability?)` | |
| `Notify(src, data)` / `NotifyNumber(number, data)` | phone banner, `data.title` required |
| `EmergencyAlert(src or -1, data)` | emergency banner |
| `SendMessage(senderNumber, senderName, targetNumber, body, opts?)` | system text message |
| `SendMail({ to, subject?, body?, from?, attachments? })` | |
| `AddBankTransaction(citizenid, { label, amount })` | |
| `IsInCall(src)` / `EndCall(src)` / `StartGroupCall(src, targets, name, number?)` | calls |
| `MessageCompany(src, { job, body })` / `PostArticle(article)` / `CreateDocument(src, { name })` | |

## Dispatch provider

`Config.Dispatch = 'Project07_Dispatch'`: `P7H.Dispatch.SendAlert(src, { type = 'storerobbery' })` uses an alert type from `/dispatchadmin`; `priority` may be `'normal'`, `'medium'`, `'high'` or 1-3.

## Owned vehicles (server, QBCore / Qbox / ESX tables)

`P7H.Vehicles.GetPlayerVehicles(uniqueId)`, `GetVehicleByPlate(plate)`, `IsOwner(uniqueId, plate)`, `SetStored(plate, garage, props)`, `SetOut(plate)`, `SaveProps(plate, props)`, `SetNickname`, `SetFavorite`, `SetMileage`, `TransferOwner(plate, targetSrc)`, `SetImpound(plate, data)`, `GetImpounded(uniqueId, location)`.

## Appearance

| Function | Side |
|---|---|
| `P7H.Appearance.FetchCurrentSkin()` / `FetchDatabaseSkin()` / `SetPlayerSkin(skin)` / `SetPlayerClothing(data)` / `ConvertSkinFormat(skin)` | client |
| `P7H.Appearance.ApplyToPed(ped, skin)` / `OpenCreator()` / `Name()` | client (character preview) |
| `P7H.Appearance.SaveCurrent()` → `true` when saved | client: saves what the ped wears now as the outfit (illenium / fivem-appearance) |
| `P7H.Appearance.GetSkin(citizenid)` → `skin, model` | server |

## Weather, spawn, housing

| Function | Side |
|---|---|
| `P7H.Weather.Pause(on, weather?)` / `Set(weather)` / `Show(weather, hour, minute)` / `Name()` | client |
| `P7H.Spawn.Open(isNew)` / `HandlesApartments()` / `Name()` | client |
| `P7H.Housing.OpenApartmentPicker(citizenid)` / `SelectApartment(apartment)` / `Enter(property)` / `Name()` | client |
| `P7H.Housing.GetApartments(fallback)` / `HasApartment(citizenid)` / `GetOwned(citizenid)` | server |

## Utilities

| Function | Side |
|---|---|
| `P7H.Utils.GetNetIdFromEntity(entity)` / `GetEntityFromNetId(netId)` | client |
| `P7H.Marker.Draw(coords, label, color)` | client |
| `P7H.Setup.Point()` / `Ped()` / `Prop(model)` | client (in-game position helpers) |
| `P7H.Logs.Send(src, title, message, webhook)` | server |
| `P7H.Debug(...)` | both (prints when `Config.Debug`) |
| `P7H.Config` | both (the Lib config) |

## Events

| Event | Side | Arguments |
|---|---|---|
| `Project7H_Lib/server/playerLoaded` | server | `src` |
| `Project7H_Lib/server/playerUnloaded` | server | `src` |
| `Project7H_Lib/client/setPlayerData` | client | player data |

## UI kit (own NUI, web/)

Notify, progress bar / circle, context menu, list menu, input + confirm dialogs, text UI and radial in the black & white clay look. Same arguments as the ox_lib functions, so a script switches by name. Look in `ui.json` (preset `clay` / `ink` / `glass` / `paper` / `steel`, accent, scale, corner size, opacity, where each part sits, radial on / off + key), pushed live through `GlobalState['p7h:ui']`; `/p7hui reload` after an edit.

| Client (after `@Project7H_Lib/imports.lua`) | Returns |
|---|---|
| `P7H.UI.Notify({ title?, description, type = 'success'/'error'/'warning'/'info', duration?, icon?, position?, id? })` | |
| `P7H.UI.ProgressBar(data)` / `P7H.UI.ProgressCircle(data)` (`duration, label, canCancel, useWhileDead, disable, anim, prop, position`) | `true` when finished (waits) |
| `P7H.UI.ProgressActive()` / `P7H.UI.CancelProgress()` | |
| `P7H.UI.RegisterContext(ctx)` / `ShowContext(id)` / `HideContext(onExit)` / `GetOpenContextMenu()` | options: `title, description, icon, iconColor, image, disabled, readOnly, arrow, progress, metadata, menu, onSelect, args, event, serverEvent` |
| `P7H.UI.RegisterMenu(data, cb)` / `ShowMenu(id)` / `HideMenu(onExit)` / `SetMenuOptions(id, options, index?)` | keyboard list: `label, description, icon, values, defaultIndex, checked, progress, args, close`; `onSelected`, `onSideScroll`, `onCheck`, `onClose` |
| `P7H.UI.InputDialog(heading, rows, { allowCancel })` | values or `nil` (waits). Rows: `input, number, checkbox, select, multi-select, slider, textarea, color, date` |
| `P7H.UI.AlertDialog({ header, content, cancel, labels })` | `'confirm'` / `'cancel'` (waits) |
| `P7H.UI.ShowTextUI(text, { icon, position, key })` / `HideTextUI()` / `IsTextUIOpen()` | `'[E] Open garage'` shows E as a key |
| `P7H.UI.AddRadialItem(items)` / `RemoveRadialItem(id)` / `RegisterRadial({ id, label, items })` / `ShowRadial()` / `HideRadial()` / `DisableRadial(state)` | radial key only when `ui.json` → `radial.enabled` |

Exports of `Project7H_Lib` with the same names (client); `InputDialog`, `AlertDialog`, `ProgressBar`, `ProgressCircle` take a callback as the last argument. Server: `P7H.UI.Notify(src, data)` / `exports.Project7H_Lib:Notify(src, data)`.

Use the kit for every script through the providers: `setr p7h:notify Project7H_Lib`, `setr p7h:progressBar Project7H_Lib`, `setr p7h:textUI Project7H_Lib`.
