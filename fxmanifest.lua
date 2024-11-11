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
  'web/build/assets/*.js',
  'web/build/assets/*.css',
  'web/build/assets/*.png',
  'web/build/assets/*.jpg',
  'web/build/assets/*.svg'
}

dependency 'spawnmanager'

exports {
    'ShowCharacterSelect'
}