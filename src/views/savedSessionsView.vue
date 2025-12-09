<template>
	<div class="mainContainer">
		<iconButton @click="$router.push('/')" id="backButton" icon="pi pi-clock" />
		<div class="timeWindows">
			<SelectButton :modelValue="timeWindowSelection" @update:modelValue="handleSelectButtonUpdate" :key="selectButtonKey" :options="['D', 'W', 'M', 'Y', 'ALL']"></SelectButton>
		</div>
		<div v-if="timeWindowSelection !== 'ALL'" class="dateNavigationContainer">
			<div @click="navigateDate(-1)" class="navArrow">
				<i class="pi pi-chevron-left"></i>
			</div>

			<span class="dateNavigationText">{{ dateDisplayString }}</span>

			<div @click="navigateDate(1)" class="navArrow">
				<i class="pi pi-chevron-right"></i>
			</div>
		</div>
		<div class="timeContainer">
			<p class="timeDisplayText">{{timeDisplay}}</p>
		</div>
		<iconButton @click="selectingProject = true" class="projectSelectionContainer" icon="pi pi-briefcase">{{projectSelection}}</iconButton>

		<ul class="sessionListContainer">
			<li v-for="session in allSessions" :key="session.id" class="sessionItem">
				<div class="leftContainer">
					<div class="dateBox">
						<div class="dateMonth">{{ formatDate(session.start_time).month }}</div>
						<div class="dateDay">{{ formatDate(session.start_time).day }}</div>
					</div>
					<DatePicker v-if="editingSessionId === session.id" v-model="editFormData.date" showIcon dateFormat="dd/mm/yy"></DatePicker>
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

	<iconButton @click="createNewSession()" icon="pi pi-plus" class="addSessionButton"></iconButton>

	<selectProjectModal v-if="selectingProject" :initialSelection="projectSelection" @closeModal="selectingProject = false" @selectProject="handleProjectSelect"/>
</template>

<script setup>
import iconButton from '@/components/buttons/iconButton.vue'
import textButton from '@/components/buttons/textButton.vue'
import { ref, computed } from "vue";
import {supabase} from "@/supabase";
import selectProjectModal from "@/modals/selectProjectModal.vue";

const timeWindowSelection = ref("D")
const projectSelection = ref("all projects")
const selectingProject = ref(false)
const selectButtonKey = ref(0)
const allSessions = ref([])
const timeDisplay = ref('00 h 00 min')
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
	duration: '',
	date: null
})
const currentReferenceDate = ref(new Date())
showProjectTime()
fetchSessions(true)

function handleSelectButtonUpdate(nextVal) {
	if (!nextVal || nextVal === timeWindowSelection.value) {
		selectButtonKey.value++
		return
	}
	timeWindowSelection.value = nextVal

	currentReferenceDate.value = new Date()

	showProjectTime()
	fetchSessions(true)
}

function navigateDate(direction) {
	const newDate = new Date(currentReferenceDate.value)

	switch (timeWindowSelection.value) {
		case 'D':
			newDate.setDate(newDate.getDate() + direction)
			break
		case 'W':
			newDate.setDate(newDate.getDate() + (direction * 7))
			break
		case 'M':
			newDate.setMonth(newDate.getMonth() + direction)
			break
		case 'Y':
			newDate.setFullYear(newDate.getFullYear() + direction)
			break
	}

	currentReferenceDate.value = newDate
	showProjectTime()
	fetchSessions(true)
}

const dateDisplayString = computed(() => {
	const date = new Date(currentReferenceDate.value)
	const lang = 'de-DE'

	switch (timeWindowSelection.value) {
		case 'D':
			return date.toLocaleDateString(lang, {day: '2-digit', month: '2-digit', year: 'numeric'})
		case 'W': {
			const startOfWeek = getStartOfWeek(date)
			const endOfWeek = new Date(startOfWeek)
			endOfWeek.setDate(endOfWeek.getDate() + 6)
			return `${startOfWeek.getDate()}.${startOfWeek.getMonth() + 1}. - ${endOfWeek.getDate()}.${endOfWeek.getMonth() + 1}.${endOfWeek.getFullYear()}`

		}
		case 'M':
			return date.toLocaleDateString(lang, { month: 'long', year: 'numeric' })
		case 'Y':
			return date.toLocaleDateString(lang, { year: 'numeric' })
		default:
			return ''
	}
})

function getStartOfWeek(date) {
	const d = new Date(date)
	const day = d.getDay()
	const diff = d.getDate() - day + (day === 0 ? -6 : 1)
	return new Date(d.setDate(diff))
}

function handleProjectSelect(selectedProjectName) {
	projectSelection.value = selectedProjectName;
	selectingProject.value = false;

	showProjectTime();
	fetchSessions(true);
}

function applyDateFiltersToQuery(query) {
	if (timeWindowSelection.value === 'ALL') return query;

	const refDate = new Date(currentReferenceDate.value);
	let startDate = null;
	let endDate = null;

	switch (timeWindowSelection.value) {
		case 'D':
			startDate = new Date(refDate.getFullYear(), refDate.getMonth(), refDate.getDate(), 0, 0, 0);
			endDate = new Date(refDate.getFullYear(), refDate.getMonth(), refDate.getDate(), 23, 59, 59);
			break;
		case 'W': {
			const start = getStartOfWeek(refDate);
			startDate = new Date(start.setHours(0,0,0,0));

			const end = new Date(start);
			end.setDate(end.getDate() + 6);
			endDate = new Date(end.setHours(23,59,59,999));
			break;
		}
		case 'M':
			startDate = new Date(refDate.getFullYear(), refDate.getMonth(), 1, 0, 0, 0);
			endDate = new Date(refDate.getFullYear(), refDate.getMonth() + 1, 0, 23, 59, 59);
			break;
		case 'Y':
			startDate = new Date(refDate.getFullYear(), 0, 1);
			endDate = new Date(refDate.getFullYear(), 11, 31, 23, 59, 59);
			break;
	}

	if (startDate && endDate) {
		query = query.gte('start_time', startDate.getTime())
				.lte('start_time', endDate.getTime());
	}

	return query;
}

function startEditing(session) {
	editingSessionId.value = session.id;

	editFormData.value = {
		description: session.description,
		projectName: getProjectNameFromCache(session.project_id),
		duration: Math.floor(session.duration / 60),
		date: session.start_time ? new Date(session.start_time) : null
	};
}

function cancelEditing() {
	editingSessionId.value = null;
	editFormData.value = {};
}

async function saveSession() {
	let projectId = null

	if (!editFormData.value.projectName) {
		const data = {
			duration: editFormData.value.duration * 60,
			description: editFormData.value.description,
		}

		if (editFormData.value.date !== undefined && editFormData.value.date !== null) {
			console.log(editFormData.value.date)
			data["start_time"] = editFormData.value.date.getTime()
		}

		await supabase
				.from('sessions')
				.update(data)
				.eq('id', editingSessionId.value)

		cancelEditing();
		await fetchSessions(true);
		return
	}

	const { data } = await supabase
			.from('projects')
			.select('id')
			.eq('name', editFormData.value.projectName)
			.eq('user_id', user.id)

	if(data.length === 0) {
		const response = await supabase
				.from('projects')
				.insert({name: editFormData.value.projectName, user_id: user.id})
				.select('id')
		projectId = response.data[0].id
	} else {
		projectId = data[0].id
	}

	await supabase
			.from('sessions')
			.update({duration: editFormData.value.duration * 60, description: editFormData.value.description, project_id: projectId})
			.eq('id', editingSessionId.value)

	cancelEditing();
	await fetchSessions(true);
}

async function deleteSession() {

	await supabase
			.from('sessions')
			.delete()
			.eq('id', editingSessionId.value);

	allSessions.value = allSessions.value.filter(s => s.id !== editingSessionId.value);

	cancelEditing();
}

async function showProjectTime() {
	let projectId = null;
	if (projectSelection.value !== 'all projects') {
		const { data } = await supabase
				.from('projects')
				.select('id')
				.eq('name', projectSelection.value)
				.eq('user_id', user.id);

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
					.eq('name', projectSelection.value)
					.eq('user_id', user.id);
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

async function createNewSession() {

	const { data } = await supabase
			.from('sessions')
			.insert({duration: undefined, description: undefined, project_id: undefined, start_time: new Date().getTime(), user_id: user.id})
			.select('id')

	editingSessionId.value = data[0].id
	await fetchSessions(true);
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
	margin-top: 10px;
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
	border: 2px solid #2c3e50;
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
	border: 1px solid #344c61 !important;
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
	border: 1px solid #344c61 !important;
}

.editInput :deep(.p-inputtext) {
	background-color: transparent !important;
	box-shadow: none !important;
	color: #2c3e50 !important;
	width: 100%;
	height: 100%;
	padding: 0 8px;
	font-family: inherit;
	font-size: 14px;
}


.editInput:focus-within {
	border: 1px solid #2c3e50 !important;
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

.leftContainer {
	display: flex;
	flex-direction: column;
	align-items: center;
	width: 65px;
	gap: 7px;
}

.addSessionButton {
	position: fixed;
	right: 30px;
	bottom: 30px;
}

.dateNavigationContainer {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: center;
	margin-top: 10px;
	width: 310px;
}

.dateNavigationText {
	color: #2c3e50;
	font-family: "Chakra Petch", sans-serif;
	font-size: 20px;
	min-width: 150px;
	text-align: center;
}

.navArrow {
	color: #2c3e50;
}

</style>