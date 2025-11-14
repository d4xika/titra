<template>
	<div class="mainContainer">
		<iconButton @click="$router.push('/')" id="backButton" icon="pi pi-clock" />
		<div class="timeWindows">
			<SelectButton :modelValue="timeWindowSelection" @update:modelValue="handleSelectButtonUpdate" :key="selectButtonKey" :options="['D', 'W', 'M', 'Y', 'ALL']"></SelectButton>
		</div>
		<div class="timeContainer">
			<p class="timeDisplayText">{{timeDisplay}}</p>
		</div>
		<iconButton @click="selectingProject = true" class="projectSelectionContainer" icon="pi pi-briefcase">{{projectSelection}}</iconButton>
	</div>

	<selectProjectModal v-if="selectingProject" :initialSelection="projectSelection" @closeModal="selectingProject = false" @selectProject="handleProjectSelect"/>
</template>

<script setup>
import iconButton from '@/components/buttons/iconButton.vue'
import {ref} from "vue";
import {supabase} from "@/supabase";
import selectProjectModal from "@/modals/selectProjectModal.vue";

const timeWindowSelection = ref("D")
const projectSelection = ref("all projects")
const selectingProject = ref(false)
const selectButtonKey = ref(0)
const allSessions = ref([])
const timeDisplay = ref('0 h 0 min')
showProjectTime()

function handleSelectButtonUpdate(nextVal) {
	if (!nextVal || nextVal === timeWindowSelection.value) {
		selectButtonKey.value++
		return
	}
	timeWindowSelection.value = nextVal
	showProjectTime()
}

function handleProjectSelect(selectedProjectName) {
	projectSelection.value = selectedProjectName;
	selectingProject.value = false;
	showProjectTime();
}

async function showProjectTime() {
	let totalDuration = 0;

	const now = new Date();
	let startDate = null;

	switch (timeWindowSelection.value) {
		case 'D':
			startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
			break;

		case 'W': {
			let heuteKopie = new Date(now.getFullYear(), now.getMonth(), now.getDate());
			const tagDerWoche = heuteKopie.getDay();

			const diff = heuteKopie.getDate() - tagDerWoche + (tagDerWoche === 0 ? -6 : 1);

			startDate = new Date(heuteKopie.setDate(diff));
			break;
		}

		case 'M':
			startDate = new Date(now.getFullYear(), now.getMonth(), 1);
			break;

		case 'Y':
			startDate = new Date(now.getFullYear(), 0, 1);
			break;

		case 'ALL':
			break;
	}

	let query = supabase
			.from('sessions')
			.select('duration');
	if (startDate) {
		query = query.gte('created_at', startDate.toISOString());
	}
	if(projectSelection.value !== 'all projects') {
		const { data } = await supabase
				.from('projects')
				.select('id')
				.eq('name', projectSelection.value)
		let projectId = data[0].id

		query = query.eq('project_id', projectId)
	}

	const { data } = await query;

	if(data) {
		allSessions.value = data

		for (let i = 0; i < allSessions.value.length; i++) {
			totalDuration += allSessions.value[i].duration;
		}

		const hours = String(Math.floor(totalDuration / 3600)).padStart(2, '0');
		const mins = String(Math.floor((totalDuration % 3600) / 60)).padStart(2, '0');
		timeDisplay.value = `${hours} h ${mins} min`;
	}
}


</script>

<style scoped>

#backButton {
	position: fixed;
	left: 30px;
	top: 30px;
}

.mainContainer {
	display: flex;
	justify-content: center;
	align-items: center;
	flex-direction: column;
	margin-top: 130px;
}

.timeContainer {
	background-color: #344c61;
	display: flex;
	justify-content: center;
	align-items: center;
	width: 330px;
	height: 120px;
	border-radius: 15px;
	margin-bottom: 10px;
	margin-top: 30px;
}

.timeWindows :deep(.p-togglebutton){
	width: 66px;
}

.timeDisplayText {
	color: lightgrey;
	font-size: xx-large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

.projectSelectionContainer {
	display: flex;
	flex-direction: row;
	justify-content: center;
	gap: 10px;
	background-color: #2c3e50;
	border-radius: 10px;
	padding: 0 15px;
	color: lightgrey;
}

</style>