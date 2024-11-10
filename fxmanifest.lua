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

ui_page('html/index.html')

files {
  'html/index.html',
  'html/style.css',
  'html/script.js'
}