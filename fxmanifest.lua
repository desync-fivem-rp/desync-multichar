-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Multi Character Framework for Desync'
author 'Braanflakes'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
}

client_scripts {
  'client.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server.lua'
}

ui_page 'web/build/index.html'

files {
  'web/build/index.html',
  'web/build/**/*'
}

dependency 'spawnmanager'

exports {
    'ShowCharacterSelect'
}