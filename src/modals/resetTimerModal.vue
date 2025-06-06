<template>
	<div id="dimmBackground">
		<div id="modal">
			<img style="height: 150px; margin-top: -200px" src="/images/sadKitty.gif" alt="sad kitty">
			<closeButton @click="this.$emit('closeModal')" id="closeButton"/>
			<p style="margin-top: 10px">Are you sure you want to reset?</p>
			<div style="display: flex; justify-content: center; flex-direction: row; margin-bottom: 15px; gap: 50px">
				<div @click="this.$emit('yesReset')" class="choiceButtons">Yes</div>
				<div @click="this.$emit('noReset')" class="choiceButtons">No</div>
			</div>
		</div>
	</div>
</template>

<script>
import closeButton from '@/components/buttons/closeButton.vue'

export default {
	name: 'finishedTimerModal',
	components: {
		closeButton
	}
}

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

#closeButton {
	position: absolute;
	right: 10px;
	top: 10px;
}

.choiceButtons {
	height: 40px;
	width: 75px;
	color: white;
	align-content: center;
	background-color: rgba(173, 216, 230, 0.5);
	border-radius: 5px;
	font-size: large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

p {
	color: white;
	font-size: x-large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

</style>