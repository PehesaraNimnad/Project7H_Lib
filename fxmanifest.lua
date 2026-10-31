fx_version 'cerulean'
name 'Project7H_Lib'
game 'gta5'
author 'Project7H'
lua54 'yes'
description 'Project7H shared library: framework, inventory, notify, target, text UI, progress, fuel, keys, appearance, weather, spawn, housing + own UI kit (notify, progress, menus, dialogs, text UI, radial)'
version '1.0.0'

client_scripts {
    'client/main.lua',
    'client/utils.lua',
    'client/cache.lua',
    'client/marker.lua',
    'client/setup.lua',
    'client/ui/*.lua', -- UI kit (web/): before the providers that can use it
    'client/appearance/*.lua',
    'client/carkeys/*.lua',
    'client/framework/*.lua',
    'client/inventory/*.lua',
    'client/notify/*.lua',
    'client/progress/*.lua',
    'client/target/*.lua',
    'client/bossmenu/*.lua',
    'client/fuel/*.lua',
    'client/dispatch/*.lua',
    'client/textui/*.lua',
    'client/phone/*.lua',
    'client/extras/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/ui.lua',
    'server/debug.lua',
    'server/logs.lua',
    'server/framework/*.lua',
    'server/vehicles/*.lua',
    'server/inventory/*.lua',
    'server/dispatch_guard.lua',
    'server/dispatch/*.lua',
    'server/notify/*.lua',
    'server/society/*.lua',
    'server/phone/*.lua',
    'server/extras/*.lua',
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

ui_page 'web/build/index.html'

files {
    'imports.lua',
    'ui.json',
    'web/build/index.html',
    'web/build/assets/*',
}
