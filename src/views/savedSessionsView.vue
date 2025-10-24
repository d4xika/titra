<template>
	<div>
		<iconButton @click="$router.push('/')" id="backButton" icon="pi pi-clock" />
	</div>
</template>

<script setup>
import iconButton from '@/components/buttons/iconButton.vue'

</script>

<style scoped>

#backButton {
	position: fixed;
	left: 30px;
	top: 30px;
}

</style>