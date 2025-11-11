<template>
	<div id="dimmBackground">
		<div id="modal">
			<img style="height: 150px; margin-top: -200px" src="/images/sadKitty.gif" alt="sad kitty">
			<p style="margin-top: 10px">Are you sure you<br>want to reset?</p>
			<div style="display: flex; justify-content: center; flex-direction: row; margin-bottom: 15px; gap: 50px">
				<textButton @click="emit('yesReset')" variant="lightVersion" text="Yes"></textButton>
				<textButton @click="emit('noReset')" variant="lightVersion" text="No"></textButton>


			</div>
		</div>
	</div>
</template>

<script setup>
import { defineEmits } from 'vue'
import textButton from '@/components/buttons/textButton.vue'

const emit = defineEmits(['closeModal'])

</script>

<style scoped>

#dimmBackground {
	display: flex;
	justify-content: center;
	align-items: center;
	position: fixed;
	width: 100%;
	height: 100%;
	background-color: rgba(34, 34, 34, 0.5);
	backdrop-filter: blur(5px);
	left: 0;
	top: 0
}

#modal {
	position: relative;
	justify-content: center;
	align-content: center;
	width: 300px;
	height: 200px;
	border-radius: 15px;
	padding: 10px;
	background-color: #2c3e50;
}

p {
	color: white;
	font-size: larger;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

</style>