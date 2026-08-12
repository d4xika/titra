<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { LiveActivities } from "live-activities";
import API from "@/helper/api.js";
import { setAuthStatus } from "@/router/router.js";
import TTDrawer from "@/components/TTDrawer.vue";

const router = useRouter();
const activityId = ref(null);
const showLoginModal = ref(false);
const showRegisterModal = ref(false);

const username = ref("");
const email = ref("");
const password = ref("");
const passwordRepeat = ref("");

async function startLiveActivity() {
  const res = await LiveActivities.start({
    value: "1",
  });

  activityId.value = res.activityId;
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

async function register() {
  if (
    username.value.length === 0 ||
    email.value.length === 0 ||
    password.value.length === 0
  ) {
    //addtoast
    return;
  }

  if (password.value !== passwordRepeat.value) {
    //addtoast
    return;
  }

  API.get("csrf").then((response) => {
    API.defaults.headers.common["X-CSRF-Token"] = response.data.csrf_token;

    API.post("users/register", {
      username: username.value,
      password: password.value,
      email: email.value,
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
  if (username.value.length === 0 || password.value.length === 0) {
    //addtoast
    return;
  }

  API.get("csrf").then((response) => {
    API.defaults.headers.common["X-CSRF-Token"] = response.data.csrf_token;

    API.post("users/login", {
      username: username.value,
      password: password.value,
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
  <div class="welcome-view">
    <div class="content-container">
      <img
        style="height: 180px"
        src="/img/kitties/happyKitty.gif"
        alt="happy kitty"
      />
      <p class="welcome-text">Welcome friend!<br />Do I already know you?</p>

      <TTTextButton @click="showLoginModal = true" text="Yes I'm back!" />
      <p @click="showRegisterModal = true" class="new-text">
        No, nice to meet you!
      </p>
    </div>
  </div>

  <!--
  <button @click="startLiveActivity()">start activity</button>
  <button @click="updateActivity()">update activity</button>
  <button @click="endActivity()">end activity</button>

  X {{ activityId }} X-->

  <TTDrawer title="Login" v-model="showLoginModal" show-divider>
    <template #body>
      <div class="auth-modal">
        <TTTextInput label="Username" v-model="username" />
        <TTTextInput label="Password" v-model="password" type="password" />
        <div class="submit-button-container">
          <TTTextButton
            @click="login()"
            text="Submit"
            variant="light-version"
          />
        </div>
      </div>
    </template>
  </TTDrawer>

  <TTDrawer title="Register" v-model="showRegisterModal" show-divider>
    <template #body>
      <div class="auth-modal">
        <TTTextInput label="Username" v-model="username" />
        <TTTextInput label="E-Mail" name="email" v-model="email" />
        <TTTextInput label="Password" v-model="password" type="password" />
        <TTTextInput
          label="Repeat Password"
          v-model="passwordRepeat"
          type="password"
        />
        <div class="submit-button-container">
          <TTTextButton
            @click="register()"
            text="Register"
            variant="light-version"
          />
        </div>
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.welcome-view {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100dvh;

  .content-container {
    display: flex;
    align-items: center;
    flex-direction: column;

    .welcome-text {
      font-size: var(--font-size-2);
      color: var(--primary-color);
    }

    .new-text {
      color: var(--primary-color);
    }
  }
}

.auth-modal {
  display: flex;
  flex-direction: column;
  padding: var(--gap-2) 0;
  gap: calc(var(--gap-2) + var(--gap-1));

  .submit-button-container {
    padding-top: var(--gap-2);
  }
}
</style>
