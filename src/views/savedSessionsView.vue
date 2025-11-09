<template>
	<div>
		<iconButton @click="$router.push('/')" id="backButton" icon="pi pi-clock" />
		<div class="timeWindows" style="margin-top: 120px">
			<SelectButton :modelValue="timeWindowSelection" @update:modelValue="handleSelectButtonUpdate" :key="selectButtonKey" :options="['D', 'W', 'M', 'Y', 'ALL']"></SelectButton>
		</div>
	</div>
</template>

<script setup>
import iconButton from '@/components/buttons/iconButton.vue'
import {ref} from "vue";

const timeWindowSelection = ref("D")
const selectButtonKey = ref(0)

function handleSelectButtonUpdate(nextVal) {
	if (!nextVal || nextVal === timeWindowSelection.value) {
		selectButtonKey.value++
		return
	}
	timeWindowSelection.value = nextVal
}


</script>

<style scoped>

#backButton {
	position: fixed;
	left: 30px;
	top: 30px;
}

.timeWindows :deep(.p-togglebutton){
	width: 66px;
}

</style>