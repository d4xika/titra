<template>
	<div class="welcomeViewContainer">
		<img style="height: 180px" src="/images/happyKitty.gif" alt="happy kitty"/>
		<p class="welcomeText">Welcome friend! Do I already know you?<br>What's your name?</p>
		<div class="signInContainer">
			<input v-model="username" class="inputBox" type="text">
			<iconButton @click="verifyUsername()" icon="pi pi-sign-in"></iconButton>
		</div>
	</div>

	<dynamic-modal v-if="showUserKnownModal" @closeModal="showUserKnownModal=false">
		<template #content>
			<p>I already know a {{username}}! Is it you?</p>
			<div class="buttonsContainer">
				<textButton @click="loginUser()" variant="lightVersion" text="Yes!"></textButton>
				<textButton @click="showUserKnownModal=false" variant="lightVersion" text="No"></textButton>
			</div>
		</template>
	</dynamic-modal>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from "@/supabase";
import iconButton from '@/components/buttons/iconButton.vue'
import DynamicModal from '@/modals/dynamicModal.vue'
import textButton from '@/components/buttons/textButton.vue'
import { useRouter } from "vue-router";

const router = useRouter()
const showUserKnownModal = ref(false)
const username = ref('')
const user = JSON.parse(localStorage.getItem('user'))
const userData = ref(null)

if (user) {
	router.push('/clock')
}

async function verifyUsername() {
	if(username.value === '') {
		return
	}

	const { data } = await supabase
			.from('users')
			.select('username, id')
			.eq('username', username.value)


	if(data.length === 0) {
		const { data } = await supabase
				.from('users')
				.insert({username: username.value })
				.select()

		const userObject = { username: username.value, id: data[0].id }
		localStorage.setItem('user', JSON.stringify(userObject) )
		router.push('/clock')
	} else {
		userData.value = data[0]
		showUserKnownModal.value = true
	}
}

function loginUser() {
	console.log(userData.value.username)
	const userObject = { username: userData.value.username, id: userData.value.id }
	localStorage.setItem('user', JSON.stringify(userObject))
	router.push('/clock')
}

</script>

<style scoped>
.welcomeText {
	font-size: x-large;
	color: #2c3e50;
	font-family: "Chakra Petch", sans-serif;
	font-weight: 550;
	font-style: normal;
}

.inputBox {
	background-color: #2c3e50;
	color: lightgrey;
	font-size: large;
	width: 150px;
	height: 40px;
	text-align: center;
	border-radius: 10px;
	border: none;
}

.inputBox:focus {
	outline: none;
}

input::placeholder {
	color: rgba(211, 211, 211, 0.9);
	font-size: x-large;
}

.welcomeViewContainer {
	display: flex;
	align-items: center;
	flex-direction: column;
}

.signInContainer {
	display: flex;
	align-items: center;
	flex-direction: row;
	gap: 10px;
}

.buttonsContainer {
	width: 100%;
	display: flex;
	justify-content: center;
	align-items: center;
	flex-direction: row;
	gap: 20px;
}

</style>