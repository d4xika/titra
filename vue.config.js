const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  pwa: {
    iconPaths: {
      favicon32: 'img/icons/kittyIconGreen_192x192.png',
      favicon16: 'img/icons/kittyIconGreen_192x192.png',
      appleTouchIcon: 'img/icons/kittyIconGreen_192x192.png',
      maskIcon: 'img/icons/kittyIconGreen_192x192.png',
      msTileImage: 'img/icons/kittyIconGreen_192x192.png'
    }
  }
})
