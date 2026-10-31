Config = {} -- [do not change this]

--@param Config.Debug: boolean [true = print debug messages]
Config.Debug = false

--@param Config.Logs: boolean [true = send logs to the discord webhook]
Config.Logs = false

--@param Config.Language: string
Config.Language = 'en'

--[[
    Every provider below can be set without editing this file: put a replicated convar in server.cfg,
    e.g.  setr p7h:framework qbox   /   setr p7h:fuel ox_fuel   (the name is p7h: + the setting in camelCase).
    'auto' picks the first resource that is installed (stopped resources count too,
    e.g. everything in [disabled]). Set the real name when two of a kind are installed.
]]

--@param Config.Framework: string [which framework you use]
Config.Framework = GetConvar('p7h:framework', 'auto')
--[[
    auto  - detect automatically
    qbox  - Qbox (qbx_core)            
    qb    - QBCore (qb-core)
    esx   - ESX (es_extended)
    ox    - ox_core
    nd    - ND Framework (ND_Core)
]]

Config.FrameworkUniqueId = {
    ['esx'] = 'id',
    ['qb'] = 'citizenid',
    ['qbox'] = 'citizenid',
    ['ox'] = 'charId',
    ['nd'] = 'charid',
}

--@param Config.Target: string [which target system you use]
Config.Target = GetConvar('p7h:target', 'auto')
--[[
    auto        - detect automatically
    ox_target   - Overextended target
    qb-target   - QBCore target
    core_focus  - Core Focus
    ContextMenu - Context Menu
    textui      - text UI + key press, no target script
]]

--@param Config.Inventory: string [which inventory you use]
Config.Inventory = GetConvar('p7h:inventory', 'auto')
--[[
    auto              - detect automatically
    ox_inventory      - Overextended inventory
    qb-inventory      - QBCore inventory
    ps-inventory      - Project Sloth inventory
    qs-inventory      - Quasar inventory
    tgiann-inventory  - Tgiann inventory
    codem-inventory   - CodeM inventory
    core_inventory    - Core inventory
    ak47_inventory    - AK47 inventory
    ak47_qb_inventory - AK47 QBCore inventory
    origen_inventory  - Origen inventory
    jaksam_inventory  - Jaksam inventory
    jpr-inventory     - JPR inventory
    one_inventory     - One Studios inventory
    hex_4_inventory   - HEX inventory v4
    S-Inventory       - S-Inventory
]]

--@param Config.Notify: string [which notifications you use]
Config.Notify = GetConvar('p7h:notify', 'auto')
--[[
    auto            - detect automatically
    ox_lib          - ox_lib notify
    qbcore          - QBCore notify
    esx             - ESX notify
    brutal          - Brutal Notify (brutal_notify)
    okok            - okokNotify
    is_ui           - Inside Scripts UI
    lation_ui       - Lation UI
    g-notifications - Groot notifications
    mNotification   - mScripts notification (client only)
    vms_notifyv2    - VMS Notify v2
    wasabi_uikit    - Wasabi UI kit
]]

--@param Config.Appearance: string [which clothing / appearance script you use]
Config.Appearance = GetConvar('p7h:appearance', 'auto')
--[[
    auto                - detect automatically
    illenium-appearance - Illenium Appearance
    fivem-appearance    - fivem-appearance
    p_appearance        - pScripts Appearance
    qf-skinmenu         - QF Skinmenu
    rcore_clothing      - rcore clothing
    crm-appearance      - CRM Appearance
    tgiann-clothing     - Tgiann clothing
    esx_skin            - ESX skin
    qb-clothing         - QBCore clothing
    qs-appearance       - Quasar Appearance
    st_clothing         - ST clothing
    um-clothing         - UM clothing
    op-clothing         - OTHERPLANET clothing
    jc_appearance       - jota-dev appearance
    The character preview (ApplyToPed / OpenCreator) supports illenium-appearance, fivem-appearance, qb-clothing.
]]

--@param Config.CarKeys: string [which vehicle keys script you use]
Config.CarKeys = GetConvar('p7h:carKeys', 'auto')
--[[
    auto                - detect automatically
    Project07_CarKeys   - Project07 car keys 
    qbx_vehiclekeys     - Qbox vehicle keys
    qb-vehiclekeys      - QBCore vehicle keys
    p_vehiclekeys       - pScripts vehicle keys (new)
    p_carkeys           - pScripts car keys (old)
    wasabi_carlock      - Wasabi car lock
    qs-vehiclekeys      - Quasar vehicle keys
    tgiann-hotwire      - Tgiann hotwire
    MrNewbVehicleKeys   - MrNewb vehicle keys
    ak47_vehiclekeys    - AK47 vehicle keys
    ak47_qb_vehiclekeys - AK47 QBCore vehicle keys
    mk_vehiclekeys      - MK vehicle keys
    mm_carkeys          - MM car keys
    cd_garage           - Codesign garage keys
    filo_vehiclekey     - Filo vehicle key
    is_carkeys          - Inside Scripts car keys
    vehicles_keys       - Jaksam vehicle keys
    LifeSaver_KeySystem - LifeSaver key system
    Renewed-Vehiclekeys - Renewed vehicle keys
    brutal_carkeys      - Brutal car keys
    sna-vehiclekeys     - SNA vehicle keys
    mani-keys           - Mani car keys
    0r-vehiclekeys      - 0Resmon vehicle keys
    ic3d_vehiclekeys    - IC3D vehicle keys
    jc_vehiclekeys      - jota-dev vehicle keys
    rd_vehiclekeys      - RD vehicle keys
    t1ger_keys          - T1GER keys
    none                - no keys script
]]

--@param Config.Fuel: string [which fuel script you use]
Config.Fuel = GetConvar('p7h:fuel', 'auto')
--[[
    auto            - detect automatically
    Project07_Fuel  - Project07 fuel  
    ox_fuel         - ox_fuel
    Renewed-Fuel    - Renewed fuel
    LegacyFuel      - LegacyFuel
    lc_fuel         - lc_fuel
    cdn-fuel        - cdn-fuel
    rcore_fuel      - rcore fuel
    x-fuel          - CodeM xFuel
    codem-fuel      - CodeM fuel
    myFuel          - myFuel
    lyre_fuel       - Lyre fuel
    okokGasStation  - okok gas station
    qs-fuelstations - Quasar fuel stations
    none            - no fuel script
]]

--@param Config.Dispatch: string [which police dispatch you use]
Config.Dispatch = GetConvar('p7h:dispatch', 'auto')
--[[
    auto               - detect automatically
    Project07_Dispatch - Project07 dispatch
    ps-dispatch        - Project Sloth dispatch
    cd_dispatch        - Codesign dispatch
    cd_dispatch3d      - Codesign dispatch 3D
    qs-dispatch        - Quasar dispatch
    tk_dispatch        - TK dispatch
    rcore_dispatch     - rcore dispatch
    core_dispatch      - Core dispatch
    lb-tablet          - LB Tablet
    kartik-mdt         - Kartik MDT
    glxs-dispatch      - Galaxis dispatch
    oxide-dispatch     - Oxide dispatch
    apex_mdt           - Apex MDT
    piotreq_gpt        - pScripts police MDT
    origen_police      - Origen police
    qf_mdt             - QF MDT
    op-dispatch        - OTHERPLANET dispatch
    0r-dispatch        - 0Resmon dispatch
    tgiann-policealert - Tgiann police alert
    wasabi_mdt         - Wasabi MDT
]]

--@param Config.ProgressBar: string [which progress bar you use]
Config.ProgressBar = GetConvar('p7h:progressBar', 'auto')
--[[
    auto           - detect automatically
    ox_lib         - ox_lib progress
    qb             - QBCore progressbar
    esx            - esx_progressbar
    qs-interface   - Quasar interface
    lation_ui      - Lation UI
    ks-progressbar - KS progressbar
]]

--@param Config.Society: string [which banking / society accounts you use]
Config.Society = GetConvar('p7h:society', 'auto')
--[[
    auto               - detect automatically
    Renewed-Banking    - Renewed banking
    qb-banking         - QBCore banking
    esx_addonaccount   - ESX addon account
    p_banking          - pScripts banking
    wasabi_banking     - Wasabi banking
    qs-banking         - Quasar banking
    okokBanking        - okok banking
    RxBanking          - RxBanking
    kartik-banking     - Kartik banking
    nfs-banking        - NFS banking
    nfs-billing        - NFS billing
    crm-banking        - CRM banking
    snipe-banking      - Snipe banking
    prism_banking      - Prism banking
    oxide-banking      - Oxide banking
    bablo-banking      - Bablo banking
    fd_banking         - FD banking
    tgg-banking        - TGG banking
    LfBanking          - LF banking
    m-Banking          - mScripts banking
    m-BossMenu         - mScripts boss menu
    nass_bosmenu       - Nass boss menu
    neon-boss          - Neon boss menu
    vms_bossmenu       - VMS boss menu
    xnr-bossmenu       - Xandir boss menu
    sd-multijob        - SD multijob
    bcs_companymanager - Bagus company manager
    none               - no society accounts
]]

--@param Config.BossMenu: string [which boss menu you use]
Config.BossMenu = GetConvar('p7h:bossMenu', 'auto')
--[[
    auto               - detect automatically
    qbx_management     - Qbox management
    qb-management      - QBCore management
    esx_society        - ESX society
    okokBossMenu       - okok boss menu
    vms_bossmenu       - VMS boss menu
    xnr-bossmenu       - Xandir boss menu
    codem-bossmenu     - CodeM boss menu
    g-bossmenu         - g-bossmenu
    bablo-bossmenu     - Bablo boss menu
    m-BossMenu         - mScripts boss menu
    neon-boss          - Neon boss menu
    tk_bosstablet      - TK boss tablet
    bcs_companymanager - Bagus company manager
]]

--@param Config.TextUI: string [which text UI you use]
Config.TextUI = GetConvar('p7h:textUI', 'auto')
--[[
    auto   - detect automatically
    ox_lib - ox_lib text UI 
]]

--@param Config.Phone: string [which phone you use]
Config.Phone = GetConvar('p7h:phone', 'auto')
--[[
    auto              - detect automatically
    sd-phone          - Samuel's phone (full client + server API, see EXPORTS.md)
    lb-phone          - LB Phone (client: ToggleDisabled only)
    npwd              - NPWD (client: ToggleDisabled only)
    qs-smartphone-pro - Quasar smartphone pro (client: ToggleDisabled only)
    yseries           - YSeries (client: ToggleDisabled only)
    none              - no phone
]]

-- These three choose at call time from what is started, so 'auto' is safe.

--@param Config.Weather: string [weather / time sync]
Config.Weather = GetConvar('p7h:weather', 'auto')
--[[
    auto                - first one started
    Project7H_Weather   - Project7H weather  
    Renewed-Weathersync - Renewed weathersync
    qb-weathersync      - QBCore weathersync
    cd_easytime         - Codesign easytime
    none                - do nothing
]]

--@param Config.Spawn: string [spawn selector]
Config.Spawn = GetConvar('p7h:spawn', 'auto')
--[[
    auto                - first one started
    Project07_Spawn     - Project07 spawn  
    Project07_DayzSpawn - DayZ copy
    Project07_RustSpawn - Rust copy
    qbx_spawn           - Qbox spawn
    last                - no selector, spawn at the last position
]]

--@param Config.Housing: string [apartments / houses]
Config.Housing = GetConvar('p7h:housing', 'auto')
--[[
    auto           - first one started
    qbx_properties - Qbox properties
    ps-housing     - Project Sloth housing
    qb-apartments  - QBCore apartments (client only)
    qb-houses      - QBCore houses
    none           - no housing
]]
