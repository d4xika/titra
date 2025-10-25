<template>
	<div id="dimmBackground">
		<div id="modal">
			<img style="height: 150px; margin-top: -110px" src="/images/happyKitty.gif" alt="happy kitty">
			<closeButton @click="emit('closeModal')" id="closeButton"/>
			<p style="margin-top: 10px">Great job!</p>
			<p style="margin-top: -20px">So proud of you!</p>
			<div class="questionsContainer">
				<div style="width: 100%">
					<p class="headerQuestions">Project Name</p>
					<AutoComplete v-model="projectName" :suggestions="projects" @complete="searchProject" :virtualScrollerOptions="{ itemSize: 38 }" optionLabel="name" optionValue="name" dropdown />
				</div>
				<div style="width: 100%">
					<p class="headerQuestions">Description</p>
					<InputText type="text" v-model="description" />
				</div>
				<textButton @click="updateProjectInfo(); emit('closeModal')" variant="lightVersion" text="save"></textButton>
			</div>
		</div>
	</div>
</template>

<script setup>
import { ref, defineEmits, defineProps } from 'vue'
import { supabase } from "@/supabase";
import closeButton from '@/components/buttons/closeButton.vue'
import textButton from '@/components/buttons/textButton.vue'
const emit = defineEmits(['closeModal'])
const projectName = ref('')
const description = ref('')
const projects = ref([])
const user = JSON.parse(localStorage.getItem('user'))
const props = defineProps({id: {type: Number}})
loadProjects()

async function loadProjects() {
	const { data } = await supabase
			.from('projects')
			.select()
			.eq('user_id', user.id)
	projects.value = data
}

function searchProject() {

}

async function updateProjectInfo() {
	const projectNameString = projectName.value.name ?? projectName.value
	let projectId = null
	const { data } = await supabase
			.from('projects')
			.select('id')
			.eq('name', projectNameString)

	if(data.length === 0) {
		const response = await supabase
				.from('projects')
				.insert({name: projectNameString, user_id: user.id})
				.select('id')
		projectId = response.data[0].id
	} else {
		projectId = data[0].id
	}
	await supabase
			.from('sessions')
			.update({ project_id: projectId, description: description.value })
			.eq('id', props.id)
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
	padding-bottom: 30px;
	border-radius: 15px;
	background-color: #2c3e50;
}

#closeButton {
	position: absolute;
	right: 10px;
	top: 10px;
}

p {
	color: white;
	font-size: x-large;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 400;
	font-style: normal;
}

.questionsContainer {
	display: flex;
	align-items: center;
	flex-direction: column;
	width: 100%;
	padding: 0 20px;
	gap: 20px;
}

.headerQuestions {
	font-size: large;
	margin: 5px;
}

</style>