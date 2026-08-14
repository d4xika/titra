<script setup>
import { ref, onMounted, computed } from "vue";
import FinishedTimerModal from "@/modals/FinishedTimerModal.vue";
import ResetTimerModal from "@/modals/ResetTimerModal.vue";
import API from "@/helper/api.js";
import { useTTToast } from "@/helper/useTTToast.js";

const timerSelection = ref("pi pi-stopwatch");
const selectButtonKey = ref(0);
const countdownStartTime = ref(null);
const sessionId = ref(null);
const toast = useTTToast();

const timer = ref({
  startTime: null,
  elapsedTime: null,
  running: false,
  display: "00:00",
  finished: false,
  reset: false,
  elapsedBeforePause: 0,
});

const isTimerActive = computed(() => {
  return timer.value.running || timer.value.elapsedBeforePause > 0;
});
const intervalId = ref(null);

function startTimer() {
  if (
    timerSelection.value === "pi pi-hourglass" &&
    (!Number.isFinite(Number(countdownStartTime.value)) ||
      Number(countdownStartTime.value) <= 0)
  ) {
    toast.warn("Enter a countdown longer than zero minutes.");
    return;
  }

  const now = Date.now();

  timer.value.startTime = now - timer.value.elapsedBeforePause * 1000;
  timer.value.running = true;
  timer.value.finished = false;

  localStorage.setItem("timerStartTime", timer.value.startTime);
  localStorage.setItem("timerRunning", "true");
  localStorage.setItem("elapsedBeforePause", timer.value.elapsedBeforePause);

  intervalId.value = setInterval(() => {
    updateTimerDisplay();
  }, 1000);

  updateTimerDisplay();
}

function pauseTimer() {
  if (!timer.value.running) return;

  timer.value.running = false;
  clearInterval(intervalId.value);

  timer.value.elapsedBeforePause = Math.floor(
    (Date.now() - timer.value.startTime) / 1000,
  );

  localStorage.setItem("elapsedBeforePause", timer.value.elapsedBeforePause);
  localStorage.setItem("timerRunning", "false");
  localStorage.removeItem("timerStartTime");
}

function resetTimer() {
  pauseTimer();

  timer.value.startTime = null;
  timer.value.elapsedBeforePause = 0;
  timer.value.display = "00:00";
  timer.value.finished = false;
  timer.value.reset = false;

  localStorage.removeItem("timerStartTime");
  localStorage.removeItem("elapsedBeforePause");
  localStorage.removeItem("timerRunning");
}

async function stopTimer() {
  if (!timer.value.running && timer.value.elapsedBeforePause <= 0) {
    toast.info("Start the timer before saving a session.");
    return;
  }

  if (timer.value.running) {
    pauseTimer();
  }

  try {
    const startTime = timer.value.startTime
      ? new Date(timer.value.startTime)
      : new Date();
    const session = await API.post("sessions", {
      session: {
        start_time: startTime.toISOString(),
        duration: timer.value.elapsedBeforePause,
        project_id: null,
        description: null,
      },
    });

    sessionId.value = session.data.id;
    resetTimer();
    timer.value.finished = true;
  } catch (error) {
    toast.apiError(error, "Could not save the timed session.");
  }
}

function updateTimerDisplay() {
  if (timer.value.running && timer.value.startTime) {
    const elapsed = Math.floor((Date.now() - timer.value.startTime) / 1000);
    timer.value.elapsedBeforePause = elapsed;

    if (timerSelection.value === "pi pi-hourglass") {
      const countdown = countdownStartTime.value * 60 - elapsed;
      timer.value.display = formatElapsed(countdown);
      if (countdown <= 0) {
        stopTimer();
      }
    } else {
      timer.value.display = formatElapsed(elapsed);
    }

    localStorage.setItem("elapsedBeforePause", elapsed);
  }
}

function formatElapsed(seconds) {
  const mins = String(Math.floor(seconds / 60)).padStart(2, "0");
  const secs = String(seconds % 60).padStart(2, "0");
  return `${mins}:${secs}`;
}

onMounted(() => {
  const wasRunning = localStorage.getItem("timerRunning") === "true";
  const savedStartTime = localStorage.getItem("timerStartTime");
  const savedElapsed = localStorage.getItem("elapsedBeforePause");

  timer.value.elapsedBeforePause = savedElapsed ? parseInt(savedElapsed) : 0;

  if (wasRunning && savedStartTime) {
    timer.value.startTime = parseInt(savedStartTime);
    timer.value.running = true;

    intervalId.value = setInterval(() => {
      updateTimerDisplay();
    }, 1000);

    updateTimerDisplay();
  } else {
    timer.value.running = false;
    timer.value.display = formatElapsed(timer.value.elapsedBeforePause);
  }
});

function handleSelectButtonUpdate(nextVal) {
  if (!nextVal || nextVal === timerSelection.value) {
    selectButtonKey.value++;
    return;
  }
  timerSelection.value = nextVal;
}
</script>

<template>
  <div class="main-view">
    <TTIconButton
      @click="$router.push('savedSessions')"
      class="list-button"
      icon="pi pi-list"
    />
    <div class="main-container">
      <TTSelectButton
        :disabled="isTimerActive"
        :modelValue="timerSelection"
        @update:model-value="handleSelectButtonUpdate"
        :key="selectButtonKey"
        :options="['pi pi-stopwatch', 'pi pi-hourglass']"
      >
        <template #option="slotProps">
          <i :class="slotProps.option"></i>
        </template>
      </TTSelectButton>
      <div>
        <img
          v-if="timer.running"
          style="height: 12.5rem; margin-bottom: var(--gap-1)"
          src="/img/kitties/workingKitty.gif"
          alt="working kitty"
        />
        <img
          v-else
          style="height: 10rem; margin-top: 3rem"
          src="/img/kitties/sleepingKitty.gif"
          alt="sleeping kitty"
        />
      </div>
      <div class="timer-box">
        <p v-if="timerSelection === 'pi pi-stopwatch' || isTimerActive">
          {{ timer.display }}
        </p>
        <input
          v-else
          class="input-box"
          placeholder="min"
          v-model="countdownStartTime"
        />
      </div>

      <div class="button-container">
        <TTIconButton @click="timer.reset = true" icon="pi pi-replay" />
        <TTIconButton
          @click="pauseTimer"
          v-if="timer.running"
          icon="pi pi-pause"
        />
        <TTIconButton @click="startTimer" v-else icon="pi pi-play" />
        <TTIconButton @click="stopTimer" icon="pi pi-stop" />
      </div>
    </div>
  </div>

  <FinishedTimerModal
    :id="sessionId"
    v-model="timer.finished"
    @closeModal="timer.finished = false"
  />
  <ResetTimerModal
    v-model="timer.reset"
    @reset="resetTimer"
    @closeModal="timer.reset = false"
  />
</template>

<style scoped>
.main-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;

  .list-button {
    position: fixed;
    left: 2rem;
    top: 2rem;
  }

  .main-container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    gap: var(--gap-2);

    .timer-box {
      background-color: var(--primary-color);
      display: flex;
      justify-content: center;
      align-items: center;
      width: 18rem;
      height: 9rem;
      border-radius: var(--border-radius-3);
      font-size: var(--font-size-4);
      box-shadow: var(--gap-2) var(--gap-2) var(--gap-3) rgba(0, 0, 0, 0.2);
    }

    .input-box {
      text-align: center;
      background-color: var(--primary-color);
      color: var(--white);
      font-size: var(--font-size-3);
      width: 8rem;
      height: 4rem;
      border: 1px solid var(--secondary-color);
      border-radius: var(--border-radius-3);

      &:focus {
        outline: none;
      }

      &::placeholder {
        font-size: var(--font-size-2);
      }
    }

    .button-container {
      display: flex;
      padding-top: var(--gap-1);
      gap: var(--gap-2);
    }
  }
}
</style>
