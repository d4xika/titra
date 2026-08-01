<script setup>
import { ref } from "vue";
import DynamicModal from "@/modals/dynamicModal.vue";
import textButton from "@/components/buttons/textButton.vue";
import { useRouter } from "vue-router";
import { LiveActivities } from "live-activities";
import API from "@/helper/api.js";
import { setAuthStatus } from "@/router/router.js";
import TTDrawer from "@/components/TTDrawer.vue";

const router = useRouter();
const user = JSON.parse(localStorage.getItem("user"));
const activityId = ref(null);
const showLoginModal = ref(false);
const showRegisterModal = ref(false);

const usernameNew = ref("");
const emailNew = ref("");
const passwordNew = ref("");
const passwordRepeat = ref("");

async function startLiveActivity() {
  const res = await LiveActivities.start({
    value: "1",
  });

  activityId.value = res.activityId;
  console.log("Started Live Activity:", res);
  return res;
}

async function updateActivity() {
  await LiveActivities.update({
    activityId: activityId.value,
    value: "40",
  });
}

async function endActivity() {
  await LiveActivities.end({ activityId: activityId.value });
}

if (user && user.username) {
  router.push("/home");
}

async function register() {
  if (
    usernameNew.value.length === 0 ||
    emailNew.value.length === 0 ||
    passwordNew.value.length === 0
  ) {
    //addtoast
    return;
  }

  if (passwordNew.value !== passwordRepeat.value) {
    //addtoast
    return;
  }

  API.get("csrf").then((response) => {
    API.defaults.headers.common["X-CSRF-Token"] = response.data.csrf_token;

    API.post("users/register", {
      username: usernameNew.value,
      password: passwordNew.value,
      email: emailNew.value,
    }).then(
      (response) => {
        localStorage.setItem("user", JSON.stringify(response.data));
        setAuthStatus(true);
        router.push("/home");
      },
      (error) => {
        console.log(error);
      },
    );
  });
}

async function login() {
  if (usernameNew.value.length === 0 || passwordNew.value.length === 0) {
    //addtoast
    return;
  }

  API.get("csrf").then((response) => {
    API.defaults.headers.common["X-CSRF-Token"] = response.data.csrf_token;

    API.post("users/login", {
      username: usernameNew.value,
      password: passwordNew.value,
    }).then(
      (response) => {
        localStorage.setItem("user", JSON.stringify(response.data));
        setAuthStatus(true);
        router.push("/home");
      },
      (error) => {
        if (error.status === 409) {
          // help
        } else {
          // help
        }
      },
    );
  });
}
</script>

<template>
  <div class="welcomeViewContainer">
    <img
      style="height: 180px"
      src="/img/kitties/happyKitty.gif"
      alt="happy kitty"
    />
    <p class="welcomeText">Welcome friend!<br />Do I already know you?</p>

    <textButton @click="showLoginModal = true" text="Yes I'm back!" />
    <p @click="showRegisterModal = true" class="new-text">
      No, nice to meet you!
    </p>
  </div>
  <!--
  <button @click="startLiveActivity()">start activity</button>
  <button @click="updateActivity()">update activity</button>
  <button @click="endActivity()">end activity</button>

  X {{ activityId }} X-->

  <TTDrawer title="Login" v-model="showLoginModal">
    <template #body>
      <div class="auth-modal">
        <TTTextInput label="Username" v-model="usernameNew" />
        <TTTextInput label="Password" v-model="passwordNew" type="password" />
        <div class="submit-button-container">
          <TextButton @click="login()" text="Submit" variant="lightVersion" />
        </div>
      </div>
    </template>
  </TTDrawer>
  <TTDrawer title="Register" v-model="showRegisterModal">
    <template #body>
      <div class="auth-modal">
        <TTTextInput label="Username" v-model="usernameNew" />
        <TTTextInput label="E-Mail" name="email" v-model="emailNew" />
        <TTTextInput label="Password" v-model="passwordNew" type="password" />
        <TTTextInput
          label="Repeat Password"
          v-model="passwordRepeat"
          type="password"
        />
        <div class="submit-button-container">
          <TextButton
            @click="register()"
            text="Register"
            variant="lightVersion"
          />
        </div>
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.welcomeViewContainer {
  display: flex;
  align-items: center;
  flex-direction: column;
  margin-top: 140px;

  .welcomeText {
    font-size: x-large;
    color: var(--primary-color);
    font-weight: 550;
    font-style: normal;
  }

  .new-text {
    color: var(--primary-color);
    font-weight: 550;
    font-style: normal;
  }
}

.auth-modal {
  display: flex;
  flex-direction: column;
  gap: calc(var(--gap-2) + var(--gap-1));

  .submit-button-container {
    padding-top: var(--gap-2);
  }
}
</style>
