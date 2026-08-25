import { createApp } from "vue";
import { Capacitor } from "@capacitor/core";
import PrimeVue from "primevue/config";
import App from "./App.vue";
import "./registerServiceWorker";
import Aura from "@primeuix/themes/aura";
import SelectButton from "primevue/selectbutton";
import AutoComplete from "primevue/autocomplete";
import InputText from "primevue/inputtext";
import InputNumber from "primevue/inputnumber";
import DatePicker from "primevue/datepicker";
import ToastService from "primevue/toastservice";
import "primeicons/primeicons.css";
import "./core.scss";
import router from "@/router/router.js";

document.documentElement.classList.toggle(
  "native-platform",
  Capacitor.isNativePlatform(),
);

const app = createApp(App);
app.use(PrimeVue, {
  locale: {
    firstDayOfWeek: 1,
  },
  theme: {
    preset: Aura,
  },
});
app.use(router);
app.use(ToastService);
app.component("SelectButton", SelectButton);
app.component("AutoComplete", AutoComplete);
app.component("InputText", InputText);
app.component("InputNumber", InputNumber);
app.component("DatePicker", DatePicker);
app.mount("#app");
