import { createApp } from 'vue'
import PrimeVue from 'primevue/config';
import App from './App.vue'
import './registerServiceWorker'
import Aura from '@primeuix/themes/aura';
import SelectButton from 'primevue/selectbutton';
import 'primeicons/primeicons.css'
import './primevue.css'

const app = createApp(App);
app.use(PrimeVue, {
    theme: {
        preset: Aura
    }
});

app.component("SelectButton", SelectButton)
app.mount('#app')
