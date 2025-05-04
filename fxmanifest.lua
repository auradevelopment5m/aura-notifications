fx_version 'cerulean'
game 'gta5'

name 'aura-notifications'
description 'Clean sleek notifications for fivem servers.'
author 'Aura Development'
version '1.0'

ui_page 'web/dist/index.html'

client_scripts {
    'runtime/client/main.lua',
}

shared_script 'config.lua'

server_scripts {
    'runtime/server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

lua54 'yes'