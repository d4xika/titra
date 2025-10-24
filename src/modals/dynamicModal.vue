<template>
	<div id="dimmBackground">
		<div id="modal">
			<closeButton @click="emit('closeModal')" id="closeButton"/>
			<slot name="content"></slot>
		</div>
	</div>
</template>

<script setup>
import { defineEmits } from 'vue'
import closeButton from '@/components/buttons/closeButton.vue'
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
	background-color: #2c3e50;
	color: white;
	font-size: large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

#closeButton {
	position: absolute;
	right: 10px;
	top: 10px;
}


</style>