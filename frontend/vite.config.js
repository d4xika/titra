import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
    plugins: [
        vue(),
        VitePWA({
            registerType: 'autoUpdate',
            includeAssets: [
                'img/icons/kittyIconBlue_192x192.png',
                'img/icons/kittyIconBlue_512x512.png'
            ],
            manifest: {
                name: 'Titra',
                short_name: 'Titra',
                theme_color: '#2c3e50',
                background_color: '#ffffff',
                display: 'standalone',
                icons: [
                    {
                        src: 'img/icons/kittyIconBlue_192x192.png',
                        sizes: '192x192',
                        type: 'image/png',
                        purpose: 'any'
                    },
                    {
                        src: 'img/icons/kittyIconBlue_512x512.png',
                        sizes: '512x512',
                        type: 'image/png',
                        purpose: 'any'
                    }
                ]
            }
        })
    ],
    resolve: {
        alias: {
            '@': fileURLToPath(new URL('./src', import.meta.url))
        }
    }
})