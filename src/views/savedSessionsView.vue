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

		<ul class="sessionListContainer">
			<li v-for="session in allSessions" :key="session.id" class="sessionItem">
				<div>
					<div class="dateBox">
						<div class="dateMonth">{{ formatDate(session.start_time).month }}</div>
						<div class="dateDay">{{ formatDate(session.start_time).day }}</div>
					</div>
				</div>

				<div class="sessionInformationContainer">
					<div v-if="editingSessionId !== session.id" class="sessionDescription">
						{{ session.description || 'working hard' }}
					</div>
					<div v-else class="sessionDescription">
						<p class="labels">Description</p>
						<InputText v-model="editFormData.description" class="editInput"/>
					</div>

					<div v-if="editingSessionId !== session.id" class="projectName">
						{{ getProjectNameFromCache(session.project_id) || 'important stuff' }}
					</div>
					<div v-else class="projectName">
						<p class="labels">Project name</p>
						<InputText v-model="editFormData.projectName" class="editInput"/>
					</div>

					<div v-if="editingSessionId !== session.id" class="sessionDuration">
						{{ formatDuration(session.duration) }}
					</div>
					<div v-else class="sessionDuration">
						<p class="labels">Duration</p>
						<InputNumber v-model="editFormData.duration" class="editInput" suffix=" min" :min="0"/>
					</div>

				</div>

				<div>
					<div v-if="editingSessionId !== session.id" @click="startEditing(session)" class="actionIcons">
						<i class="pi pi-pencil"></i>
					</div>

					<div class="actionColumn">
						<div v-if="editingSessionId === session.id" class="actionIcons">
							<i class="pi pi-check" @click="saveSession()"></i>
							<i class="pi pi-times" @click="cancelEditing()"></i>
						</div>

						<div v-if="editingSessionId === session.id" class="actionIcons">
							<i class="pi pi-trash actionIcon deleteIcon" @click="deleteSession(session.id)"></i>
						</div>
					</div>
				</div>
			</li>
		</ul>

		<textButton v-if="canLoadMore && !isLoadingSessions" @click="fetchSessions(false)" text="Load More"/>
	</div>

	<selectProjectModal v-if="selectingProject" :initialSelection="projectSelection" @closeModal="selectingProject = false" @selectProject="handleProjectSelect"/>
</template>

<script setup>
import iconButton from '@/components/buttons/iconButton.vue'
import textButton from '@/components/buttons/textButton.vue'
import { ref } from "vue";
import {supabase} from "@/supabase";
import selectProjectModal from "@/modals/selectProjectModal.vue";

const timeWindowSelection = ref("D")
const projectSelection = ref("all projects")
const selectingProject = ref(false)
const selectButtonKey = ref(0)
const allSessions = ref([])
const timeDisplay = ref('0 h 0 min')
const user = JSON.parse(localStorage.getItem('user'))
const sessionsPerPage = ref(10)
const currentPage = ref(0)
const canLoadMore = ref(true)
const isLoadingSessions = ref(true)
const projectNamesCache = ref({})
const editingSessionId = ref(null)
const editFormData = ref({
	description: '',
	projectName: '',
	duration: ''
})
showProjectTime()
fetchSessions(true)

function handleSelectButtonUpdate(nextVal) {
	if (!nextVal || nextVal === timeWindowSelection.value) {
		selectButtonKey.value++
		return
	}
	timeWindowSelection.value = nextVal

	showProjectTime()
	fetchSessions(true)
}

function handleProjectSelect(selectedProjectName) {
	projectSelection.value = selectedProjectName;
	selectingProject.value = false;

	showProjectTime();
	fetchSessions(true);
}

function applyDateFiltersToQuery(query) {
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

	if (startDate) {
		query = query.gte('created_at', startDate.toISOString());
	}

	return query;
}

/*function openCalender() {
	if(!sessionEditMode.value) {
		return
	}
}*/

function startEditing(session) {
	editingSessionId.value = session.id;

	editFormData.value = {
		description: session.description,
		projectName: getProjectNameFromCache(session.project_id),
		duration: Math.floor(session.duration / 60)
	};
}

function cancelEditing() {
	editingSessionId.value = null;
	editFormData.value = {};
}

function saveSession() {
	//TODO: saveSession Logik

	cancelEditing();
}

function deleteSession() {
	//TODO: deleteSession Logik

	cancelEditing();
}

async function showProjectTime() {
	let projectId = null;
	if (projectSelection.value !== 'all projects') {
		const { data } = await supabase
				.from('projects')
				.select('id')
				.eq('name', projectSelection.value);

		if (data && data.length > 0) {
			projectId = data[0].id;
		}
	}

	let query = supabase
			.from('sessions')
			.select('duration')
			.eq('user_id', user.id);
	query = applyDateFiltersToQuery(query);
	if (projectId) {
		query = query.eq('project_id', projectId);
	}

	const { data } = await query;

	if (data) {
		let totalDuration = 0;
		data.forEach(session => {
			totalDuration += session.duration;
		});
		timeDisplay.value = formatDuration(totalDuration);
	}
}

async function fetchSessions(reset = false) {
	if (isLoadingSessions.value && !reset) return;

	isLoadingSessions.value = true;

	if (reset) {
		currentPage.value = 0;
		allSessions.value = [];
		canLoadMore.value = true;
	}

	try {

		const offset = currentPage.value * sessionsPerPage.value;
		const rangeEnd = offset + sessionsPerPage.value - 1;

		let projectId = null;
		if (projectSelection.value !== 'all projects') {
			const { data } = await supabase
					.from('projects')
					.select('id')
					.eq('name', projectSelection.value);
			if (data && data.length > 0) {
				projectId = data[0].id;
			}
		}

		let query = supabase
				.from('sessions')
				.select('id, start_time, duration, description, project_id')
				.eq('user_id', user.id);
		query = applyDateFiltersToQuery(query);
		if (projectId) {
			query = query.eq('project_id', projectId);
		}

		const { data, error } = await query
				.order('start_time', { ascending: false })
				.range(offset, rangeEnd);

		if (data && data.length > 0) {
			allSessions.value = [...allSessions.value, ...data];
			currentPage.value++;
			if (data.length < sessionsPerPage.value) {
				canLoadMore.value = false;
			}
		} else if (error) {
			console.error('Error while loading sessions: ', error.message);
			canLoadMore.value = false;
		} else {
			canLoadMore.value = false;
		}

		const uniqueProjectIds = [...new Set(data.map(s => s.project_id).filter(id => id != null))];
		uniqueProjectIds.forEach(id => fetchProjectName(id));

	} catch (e) {
		console.error(e);
		canLoadMore.value = false;
	} finally {
		isLoadingSessions.value = false;
	}
}

function getProjectNameFromCache(projectId) {
	return projectNamesCache.value[projectId];
}

async function fetchProjectName(projectId) {
	if (projectNamesCache.value[projectId]) {
		return;
	}

	const { data } = await supabase
			.from('projects')
			.select('name')
			.eq('id', projectId)

	if (data && data.length > 0) {
		projectNamesCache.value[projectId] = data[0].name;
	}
}

function formatDuration(totalSeconds) {
	if (!totalSeconds) totalSeconds = 0;
	const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, '0');
	const mins = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, '0');
	return `${hours} h ${mins} min`;
}

function formatDate (dateString) {
	if (!dateString) return { month: 'HOT', day: '69' };

	const date = new Date(dateString);

	const monthOptions = { month: 'short'};

	const month = date.toLocaleDateString('en-US', monthOptions).toUpperCase();
	const day = date.getDate().toString().padStart(2, '0');

	return { month, day };
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
	margin-top: 100px;
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

.sessionListContainer {
	list-style: none;
	padding: 0;
	width: 330px;
	margin-top: 20px;
	display: flex;
	flex-direction: column;
	gap: 10px;
}

.sessionItem {
	background-color: lightblue;
	border: 3px solid #2c3e50;
	border-radius: 10px;
	padding: 10px 10px;
	display: flex;
	justify-content: center;
	gap: 15px;
	color: #2c3e50;
	font-family: "Chakra Petch", sans-serif;
}

.sessionDescription {
	font-size: medium;
	font-weight: 600;
	color: #2c3e50;
	width: 100%;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	margin-bottom: 2px;
}
.sessionDuration {
	font-size: medium;
	color: #2c3e50;
	width: 100%;
}

.dateBox {
	background-color: #344c61;
	padding-top: 3px;
	color: lightgrey;
	border-radius: 7px;
	width: 65px;
	height: 65px;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.sessionInformationContainer {
	display: flex;
	justify-content: center;
	flex-direction: column;
	flex-grow: 1;
	min-width: 0;
	align-items: flex-start;
	text-align: left;
	padding-right: 10px;
}

.projectName {
	font-size: 13px;
	color: #344c61;
	width: 100%;
	margin-bottom: 5px;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.actionColumn {
	display: flex;
	flex-direction: column;
	justify-content: space-between;
	align-items: center;
	padding: 5px 0;
	height: 100%;
}

.actionIcons {
	cursor: pointer;
}

.dateMonth {
	font-size: small;
}

.dateDay {
	font-size: x-large;
}

.editInput {
	width: 100%;
	box-sizing: border-box;
	background-color: lightblue;
	color: #2c3e50;
	border: 1px solid #344c61;
	border-radius: 4px;
	display: flex;
	align-items: center;
	height: 30px;
	font-family: inherit;
	font-size: 14px;
	margin-bottom: 5px;
}

.editInput.p-inputnumber {
	padding: 0;
	border: 1px solid #344c61;
}

.editInput :deep(.p-inputtext) {
	background-color: transparent !important;
	border: none !important;
	box-shadow: none !important;
	color: #2c3e50 !important;
	width: 100%;
	height: 100%;
	padding: 0 8px;
	font-family: inherit;
	font-size: 14px;
}


.editInput:focus-within {
	border-color: #2c3e50;
}

.editInput :deep(.p-inputtext:focus) {
	outline: none !important;
}

.labels {
	margin: 0 0 4px 0;
	font-size: 15px;
	font-weight: bold;
	color: #2c3e50;
	text-align: left;
	display: block;
	width: 100%;
}

</style>