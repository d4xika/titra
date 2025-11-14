<template>
<div class="buttonContainer">
	<i :class="props.icon"></i>
	<slot></slot>
</div>
</template>

<script setup>
import {defineProps} from 'vue'
const props = defineProps({
	icon: {
		type: String,
	}
})
</script>

<style scoped>
.buttonContainer {
	background-color: #2c3e50;
	min-width: 40px;
	min-height: 40px;
	display: flex;
	justify-content: center;
	align-items: center;
	color: lightgrey;
	border-radius: 10px;
	cursor: pointer;
	transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.buttonContainer:hover {
	transform: scale(1.05);
	box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}

</style>