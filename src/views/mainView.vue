<template>
	<div id="background"></div>
	<div>
		<div style="display: flex; justify-content: center; align-items: center; flex-direction: column">
			<div>
				<img v-if="this.timer.running" style="height: 200px; margin-bottom: 5px; margin-top: 50px" src="/images/workingKitty.gif" alt="working kitty" />
				<img v-else style="height: 160px; margin-top: 95px" src="/images/sleepingKitty.gif" alt="sleeping kitty" />
			</div>
			<div id="timerBox">
				<p>{{this.timer.display}}</p>
			</div>
		</div>
		<div style="display: flex; justify-content: center; gap: 7px; margin-top: 7px">
			<circleButton @click="this.timer.reset = true" icon="restart"/>
			<circleButton @click="this.pauseTimer" v-if="this.timer.running" icon="pause"/>
			<circleButton @click="this.startTimer" v-else icon="resume"/>
			<circleButton @click="this.stopTimer" icon="stop"/>
		</div>
	</div>

	<finishedTimerModal v-if="this.timer.finished" @closeModal="this.timer.finished = false"/>
	<resetTimerModal v-if="this.timer.reset" @yesReset="this.resetTimer" @closeModal="this.timer.reset = false" @noReset="this.timer.reset = false"/>
</template>

<script>
import circleButton from '@/components/buttons/circleButton.vue'
import finishedTimerModal from '@/modals/finishedTimerModal.vue'
import resetTimerModal from "@/modals/resetTimerModal.vue";

export default {
	name: 'mainView',
	components: {
		circleButton,
		finishedTimerModal,
		resetTimerModal
	},
	data() {
		return {
			timer: {
				startTime: null,
				passedTime: null,
				running: false,
				display: "00:00",
				finished: false,
				reset: false,
				elapsedBeforePause: 0,
			},
			intervalId: null
		}
	},
	methods: {
		startTimer() {
			if (this.timer.running) return;

			const now = Date.now();

			this.timer.startTime = now - this.timer.elapsedBeforePause * 1000;
			this.timer.running = true;
			this.timer.finished = false;

			localStorage.setItem('timerStartTime', this.timer.startTime);
			localStorage.setItem('timerRunning', 'true');
			localStorage.setItem('elapsedBeforePause', this.timer.elapsedBeforePause);

			this.intervalId = setInterval(() => {
				this.updateTimerDisplay();
			}, 1000);

			this.updateTimerDisplay();
		},

		pauseTimer() {
			if (!this.timer.running) return;

			this.timer.running = false;
			clearInterval(this.intervalId);

			this.timer.elapsedBeforePause = Math.floor((Date.now() - this.timer.startTime) / 1000);

			localStorage.setItem('elapsedBeforePause', this.timer.elapsedBeforePause);
			localStorage.setItem('timerRunning', 'false');
			localStorage.removeItem('timerStartTime');
		},

		resetTimer() {
			this.pauseTimer();

			this.timer.startTime = null;
			this.timer.elapsedBeforePause = 0;
			this.timer.display = "00:00";
			this.timer.finished = false;
			this.timer.reset = false;

			localStorage.removeItem('timerStartTime');
			localStorage.removeItem('elapsedBeforePause');
			localStorage.removeItem('timerRunning');
		},

		stopTimer() {
			this.resetTimer();
			this.timer.finished = true;
		},

		updateTimerDisplay() {
			if (this.timer.running && this.timer.startTime) {
				const elapsed = Math.floor((Date.now() - this.timer.startTime) / 1000);
				this.timer.elapsedBeforePause = elapsed;
				this.timer.display = this.formatElapsed(elapsed);

				localStorage.setItem('elapsedBeforePause', elapsed);
			}
		},

		formatElapsed(seconds) {
			const mins = String(Math.floor(seconds / 60)).padStart(2, '0');
			const secs = String(seconds % 60).padStart(2, '0');
			return `${mins}:${secs}`;
		}
	},

	mounted() {
		const wasRunning = localStorage.getItem('timerRunning') === 'true';
		const savedStartTime = localStorage.getItem('timerStartTime');
		const savedElapsed = localStorage.getItem('elapsedBeforePause');

		this.timer.elapsedBeforePause = savedElapsed ? parseInt(savedElapsed) : 0;

		if (wasRunning && savedStartTime) {
			this.timer.startTime = parseInt(savedStartTime);
			this.timer.running = true;

			this.intervalId = setInterval(() => {
				this.updateTimerDisplay();
			}, 1000);

			this.updateTimerDisplay();
		} else {
			this.timer.running = false;
			this.timer.display = this.formatElapsed(this.timer.elapsedBeforePause);
		}
	}
}

</script>

<style scoped>

#background {
	background-color: lightblue;
	top: 0;
	left: 0;
	z-index: -1;
	position: fixed;
	width: 100%;
	height: 100%;
}

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

p {
	color: lightgrey;
	font-size: xxx-large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}


</style>