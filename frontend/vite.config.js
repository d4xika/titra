import { defineConfig } from "vite";
import { PrimeVueResolver } from "@primevue/auto-import-resolver";
import vue from "@vitejs/plugin-vue";
import Components from "unplugin-vue-components/vite";
import { VitePWA } from "vite-plugin-pwa";
import { fileURLToPath, URL } from "node:url";

export default defineConfig({
  plugins: [
    vue(),
    Components({
      resolvers: [PrimeVueResolver()],
      dirs: ["src/components", "src/views/sections"],
      extensions: ["vue"],
      deep: true,
      dts: true,
    }),
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["img/icons/kitty-icon-new.png"],
      manifest: {
        name: "Titra",
        short_name: "Titra",
        theme_color: "#2c3e50",
        background_color: "#ffffff",
        display: "standalone",
        icons: [
          {
            src: "img/icons/kitty-icon-new.png",
            type: "image/png",
            purpose: "any",
          },
        ],
      },
    }),
  ],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  server: {
    port: 8000,
    strictPort: true,
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        changeOrigin: false,
      },
    },
  },
});
