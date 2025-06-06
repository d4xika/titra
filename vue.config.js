const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  pwa: {
    iconPaths: {
      favicon32: 'img/icons/kittyIconBlue_192x192.png',
      favicon16: 'img/icons/kittyIconBlue_192x192.png',
      appleTouchIcon: 'img/icons/kittyIconBlue_192x192.png',
      maskIcon: 'img/icons/kittyIconBlue_192x192.png',
      msTileImage: 'img/icons/kittyIconBlue_192x192.png'
    }
  }
})
