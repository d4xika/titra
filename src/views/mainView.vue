<template>
	<div id="background"></div>
	<div>
		<div style="display: flex; justify-content: center; align-items: center; flex-direction: column">
			<div>
				<img v-if="this.timer.running" style="height: 200px; margin-bottom: 5px" src="/images/workingKitty.gif" alt="working kitty" />
				<img v-else style="height: 160px; margin-top: 45px" src="/images/sleepingKitty.GIF" alt="sleeping kitty" />
			</div>
			<div id="timerBox">
				<p>{{this.timer.display}}</p>
			</div>
		</div>
		<div style="display: flex; justify-content: center; gap: 7px; margin-top: 7px">
			<circleButton @click="this.resetTimer" icon="restart"/>
			<circleButton @click="this.pauseTimer" v-if="this.timer.running" icon="pause"/>
			<circleButton @click="this.startTimer" v-else icon="resume"/>
			<circleButton @click="this.stopTimer" icon="stop"/>
		</div>
	</div>

	<finishedTimerModal v-if="this.timer.finished" @closeModal="this.timer.finished = false"/>
</template>

<script>
import circleButton from '@/components/buttons/circleButton.vue'
import finishedTimerModal from '@/modals/finishedTimerModal.vue'

export default {
	name: 'mainView',
	components: {
		circleButton,
		finishedTimerModal
	},
	data() {
		return {
			timer: {
				startTime: null,
				passedTime: null,
				running: false,
				display: "00:00",
				finished: false
			},
			intervalId: null
		}
	},
	methods: {
		changeTimerFormat() {
			if (!this.timer.startTime) return;

			let passed = Math.floor((Date.now() - this.timer.startTime) / 1000);
			let minutes = String(Math.floor(passed / 60)).padStart(2, '0');
			let seconds = String(passed % 60).padStart(2, '0');
			this.timer.display = `${minutes}:${seconds}`;
		},

		startTimer() {
			if(this.timer.running) return

			this.timer.running = true
			this.timer.startTime = Date.now()

			localStorage.setItem('timerStartTime', this.timer.startTime);
			localStorage.setItem('timerRunning', 'true');

			this.intervalId = setInterval(() => {
				this.changeTimerFormat();
			}, 1000);


			this.changeTimerFormat()

		},

		pauseTimer() {
			this.timer.running = false
			clearInterval(this.intervalId)
		},

		resetTimer() {
			this.pauseTimer();
			this.timer.startTime = null;
			this.timer.display = "00:00";
			this.timer.finished = false;

			localStorage.removeItem('timerStartTime');
			localStorage.removeItem('timerRunning');
		},

		stopTimer() {
			this.pauseTimer();
			this.timer.finished = true;
			this.timer.display = "00:00";

			localStorage.removeItem('timerStartTime');
			localStorage.removeItem('timerRunning');
		}

	},

	mounted() {
		const savedStartTime = localStorage.getItem('timerStartTime');
		const wasRunning = localStorage.getItem('timerRunning') === 'true';

		if (savedStartTime && wasRunning) {
			this.timer.startTime = parseInt(savedStartTime);
			this.timer.running = true;

			this.intervalId = setInterval(() => {
				this.changeTimerFormat();
			}, 1000);

			this.changeTimerFormat();
		} else {
			this.resetTimer();
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