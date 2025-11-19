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
						<div class="dateMonth">
							{{formatDate(session.start_time).month}}
						</div>
						<div class="dateDay">
							{{formatDate(session.start_time).day}}
						</div>
					</div>
				</div>
				<div class="sessionInformationContainer">
					<div class="sessionDescription">
                        {{ session.description || 'working hard' }}
					</div>
					<div class="projectName">
						{{ getProjectNameFromCache(session.project_id)  || 'important stuff (probably)' }}
					</div>
					<div class="sessionDuration">
                        {{ formatDuration(session.duration) }}
                    </div>
				</div>
				<div>
					<div class="actionIcons">
						<i class="pi pi-pencil"></i>
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
	gap: 15px;
	color: #2c3e50;
	font-family: "Chakra Petch", sans-serif;
}

.sessionDescription {
	font-size: medium;
	font-weight: bold;
	width: fit-content;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
	max-width: 180px;
}
.sessionDuration {
	font-size: medium;
	width: fit-content;
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
	justify-content: start;
	flex-direction: column;
	flex-grow: 1;
}

.projectName {
	font-size: small;
	margin-bottom: 7px;
	width: fit-content;
}

.actionIcons {
	cursor: pointer;
	padding: 4px;
}

.dateMonth {
	font-size: small;
}

.dateDay {
	font-size: x-large;
}


</style>