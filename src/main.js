import { createApp } from 'vue'
import PrimeVue from 'primevue/config';
import App from './App.vue'
import './registerServiceWorker'
import Aura from '@primeuix/themes/aura';
import SelectButton from 'primevue/selectbutton';
import 'primeicons/primeicons.css'
import './primevue.css'
import { createWebHistory, createRouter } from 'vue-router'

import mainView from '@/views/mainView.vue'
import savedSessionsView from '@/views/savedSessionsView.vue'
import welcomeView from '@/views/welcomeView.vue'

const routes = [
    { path: '/clock', component: mainView },
    { path: '/savedSessions', component: savedSessionsView },
    { path: '/', component: welcomeView }
]

export const router = createRouter({
    history: createWebHistory(),
    routes,
})

const app = createApp(App);
app.use(PrimeVue, {
    theme: {
        preset: Aura
    }
});
app.use(router)
app.component("SelectButton", SelectButton)
app.mount('#app')
