import { createApp } from 'vue'
import PrimeVue from 'primevue/config';
import App from './App.vue'
import './registerServiceWorker'
import Aura from '@primeuix/themes/aura';
import SelectButton from 'primevue/selectbutton';
import AutoComplete from "primevue/autocomplete";
import InputText from "primevue/inputtext";
import InputNumber from 'primevue/inputnumber';
import DatePicker from 'primevue/datepicker';
import 'primeicons/primeicons.css'
import './primevue.css'
import { router } from '@/router/router.js'

const app = createApp(App);
app.use(PrimeVue, {
    locale: {
        firstDayOfWeek: 1
    },
    theme: {
        preset: Aura
    }
});
app.use(router)
app.component("SelectButton", SelectButton)
app.component("AutoComplete", AutoComplete)
app.component("InputText", InputText)
app.component("InputNumber", InputNumber)
app.component("DatePicker", DatePicker)
app.mount('#app')
