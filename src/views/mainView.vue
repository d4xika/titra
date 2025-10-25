<template>
	<div>
		<iconButton @click="$router.push('savedSessions')" id="listButton" icon="pi pi-list" />
		<div style="display: flex; justify-content: center; align-items: center; flex-direction: column; margin-top: 120px">
			<SelectButton :disabled="timer.activeTimer" :modelValue="timerSelection" @update:modelValue="handleSelectButtonUpdate" :key="selectButtonKey" :options="['pi pi-stopwatch', 'pi pi-hourglass']">
				<template #option="slotProps">
					<i :class="slotProps.option"></i>
				</template>
			</SelectButton>
				<div>
				<img v-if="timer.running" style="height: 200px; margin-bottom: 5px" src="/images/workingKitty.gif" alt="working kitty"/>
				<img v-else style="height: 160px; margin-top: 45px" src="/images/sleepingKitty.gif" alt="sleeping kitty"/>
			</div>
			<div id="timerBox">
				<p v-if="timerSelection === 'pi pi-stopwatch' || timer.activeTimer">{{timer.display}}</p>
				<input v-else id="inputBox" placeholder="min" v-model="countdownStartTime">
			</div>
		</div>
		<div style="display: flex; justify-content: center; gap: 7px; margin-top: 7px">
			<circleButton @click="timer.reset = true" icon="restart"/>
			<circleButton @click="pauseTimer" v-if="timer.running" icon="pause"/>
			<circleButton @click="startTimer" v-else icon="resume"/>
			<circleButton @click="stopTimer" icon="stop"/>
		</div>
	</div>

	<finishedTimerModal :id="sessionId" v-if="timer.finished" @closeModal="timer.finished = false"/>
	<resetTimerModal v-if="timer.reset" @yesReset="resetTimer" @closeModal="timer.reset = false" @noReset="timer.reset = false"/>
</template>

<script setup>
import { ref } from "vue";
import circleButton from '@/components/buttons/circleButton.vue'
import finishedTimerModal from '@/modals/finishedTimerModal.vue'
import resetTimerModal from "@/modals/resetTimerModal.vue";
import iconButton from '@/components/buttons/iconButton.vue'
import { saveSession } from "@/supabase";

const timerSelection = ref("pi pi-stopwatch")
const selectButtonKey = ref(0)
const countdownStartTime = ref(null)
const sessionId = ref(null)

const timer = ref({
	startTime: null,
	elapsedTime: null,
	running: false,
	display: "00:00",
	finished: false,
	reset: false,
	elapsedBeforePause: 0,
	activeTimer: false
})
const intervalId = ref(null);

function startTimer() {
	const now = Date.now();

	timer.value.startTime = now - timer.value.elapsedBeforePause * 1000;
	timer.value.running = true;
	timer.value.finished = false;
	timer.value.activeTimer = true;

	localStorage.setItem('timerStartTime', timer.value.startTime);
	localStorage.setItem('timerRunning', 'true');
	localStorage.setItem('elapsedBeforePause', timer.value.elapsedBeforePause);

	intervalId.value = setInterval(() => {
		updateTimerDisplay();
	}, 1000);

	updateTimerDisplay();
}

function pauseTimer() {
	if (!timer.value.running) return;

	timer.value.running = false;
	clearInterval(intervalId);

	timer.value.elapsedBeforePause = Math.floor((Date.now() - timer.value.startTime) / 1000);

	localStorage.setItem('elapsedBeforePause', timer.value.elapsedBeforePause);
	localStorage.setItem('timerRunning', 'false');
	localStorage.removeItem('timerStartTime');
}

function resetTimer() {
	pauseTimer();

	timer.value.startTime = null;
	timer.value.elapsedBeforePause = 0;
	timer.value.display = "00:00";
	timer.value.finished = false;
	timer.value.reset = false;
	timer.value.activeTimer = false;

	localStorage.removeItem('timerStartTime');
	localStorage.removeItem('elapsedBeforePause');
	localStorage.removeItem('timerRunning');
}


async function stopTimer() {
	sessionId.value = await saveSession(timer.value.startTime, timer.value.elapsedBeforePause, null, null)
	resetTimer();
	timer.value.finished = true;
	timer.value.activeTimer = false;
}


function updateTimerDisplay() {
	if (timer.value.running && timer.value.startTime) {
		const elapsed = Math.floor((Date.now() - timer.value.startTime) / 1000);
		timer.value.elapsedBeforePause = elapsed;

		if(timerSelection.value === 'pi pi-hourglass') {
			const countdown = countdownStartTime.value * 60 - elapsed
			timer.value.display = formatElapsed(countdown)
			if(countdown <= 0) {
				stopTimer()
			}
		} else {
			timer.value.display = formatElapsed(elapsed);
		}

		localStorage.setItem('elapsedBeforePause', elapsed);
	}
}

function formatElapsed(seconds) {
	const mins = String(Math.floor(seconds / 60)).padStart(2, '0');
	const secs = String(seconds % 60).padStart(2, '0');
	return `${mins}:${secs}`;
}

const wasRunning = localStorage.getItem('timerRunning') === 'true';
const savedStartTime = localStorage.getItem('timerStartTime');
const savedElapsed = localStorage.getItem('elapsedBeforePause');

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

function handleSelectButtonUpdate(nextVal) {
	if (!nextVal || nextVal === timerSelection.value) {
		selectButtonKey.value++
		return
	}
	timerSelection.value = nextVal
}

</script>

<style scoped>

#timerBox {
	background-color: #2c3e50;
	display: flex;
	justify-content: center;
	align-items: center;
	width: 300px;
	height: 150px;
	border-radius: 15px;
	margin-bottom: 10px;
	margin-top: 10px;
}

#inputBox {
	background-color: #2c3e50;
	color: lightgrey;
	font-size: xxx-large;
	width: 140px;
	height: 70px;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
	border: 1px solid lightblue;
	border-radius: 15px;
	text-align: center;
}

#inputBox:focus {
	outline: none;
}

input::placeholder {
	color: rgba(211, 211, 211, 0.9);
	font-size: x-large;
}

p {
	color: lightgrey;
	font-size: xxx-large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

#listButton {
	position: fixed;
	left: 30px;
	top: 30px;
}


</style>