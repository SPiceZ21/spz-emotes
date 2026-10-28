fx_version 'cerulean'
game 'gta5'

name 'spz-emotes'
description 'SPiceZ emote menu: dances, gestures, poses, shared emotes, walk styles and moods'
version '1.0.0'
author 'SPiceZ-Core'
lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'shared/emotes.lua',
}

client_scripts {
  'client/play.lua',
  'client/shared.lua',
  'client/menu.lua',
  'client/recorder.lua',
}

server_scripts {
  'server/main.lua',
}

ui_page 'ui/index.html'

files {
  'ui/index.html',
  'ui/style.css',
  'ui/app.js',
  'ui/fonts/*.ttf',
  'ui/previews/*.jpg',
}

dependencies {
  'ox_lib',
  'spz-core',
}
