<script setup>
import { ref } from "vue";
import DynamicModal from "@/modals/dynamicModal.vue";
import textButton from "@/components/buttons/textButton.vue";
import { useRouter } from "vue-router";
import { LiveActivities } from "live-activities";
import API from "@/helper/api.js";
import { setAuthStatus } from "@/router/router.js";

const router = useRouter();
const showUserKnownModal = ref(false);
const username = ref("");
const user = JSON.parse(localStorage.getItem("user"));
const userData = ref(null);
const activityId = ref(null);

const usernameNew = ref("");
const emailNew = ref("");
const passwordNew = ref("");

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

function loginUser() {
  console.log(userData.value.username);
  const userObject = {
    username: userData.value.username,
    id: userData.value.id,
  };
  localStorage.setItem("user", JSON.stringify(userObject));
  router.push("/home");
}

async function registerNew() {
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

async function loginNew() {
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
    <p class="welcomeText">
      Welcome friend!<br />Do I already know you?<br />What's your name?
    </p>
  </div>

  <button @click="startLiveActivity()">start activity</button>
  <button @click="updateActivity()">update activity</button>
  <button @click="endActivity()">end activity</button>

  X {{ activityId }} X

  <div style="display: flex; flex-direction: column; gap: 10px">
    <input v-model="usernameNew" type="text" />
    <input v-model="emailNew" type="text" />
    <input v-model="passwordNew" type="text" />
    <button @click="registerNew()">register</button>
  </div>

  <div style="display: flex; flex-direction: column; gap: 10px">
    <input v-model="usernameNew" type="text" />
    <input v-model="passwordNew" type="text" />
    <button @click="loginNew()">login</button>
  </div>

  <dynamic-modal
    v-if="showUserKnownModal"
    @closeModal="showUserKnownModal = false"
  >
    <template #content>
      <p>I already know a {{ username }}!<br />Is it you?</p>
      <div class="buttonsContainer">
        <textButton
          @click="loginUser()"
          variant="lightVersion"
          text="Yes!"
        ></textButton>
        <textButton
          @click="showUserKnownModal = false"
          variant="lightVersion"
          text="No"
        ></textButton>
      </div>
    </template>
  </dynamic-modal>
</template>

<style scoped>
.welcomeText {
  font-size: x-large;
  color: #2c3e50;
  font-family: "Chakra Petch", sans-serif;
  font-weight: 550;
  font-style: normal;
}

.welcomeViewContainer {
  display: flex;
  align-items: center;
  flex-direction: column;
  margin-top: 140px;
}

.signInContainer {
  display: flex;
  align-items: center;
  flex-direction: row;
  gap: 10px;
}

.buttonsContainer {
  width: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: row;
  gap: 20px;
}
</style>
