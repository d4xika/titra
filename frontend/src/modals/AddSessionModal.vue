<script setup>
import { ref, computed } from "vue";
import API from "@/helper/api.js";

const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["sessionAdded", "closeModal"]);

const projectName = ref("");
const description = ref("");
const duration = ref(0);
const date = ref(new Date());
const allProjects = ref([]);

loadProjects();

async function loadProjects() {
  try {
    const response = await API.get("projects");
    allProjects.value = response.data;
  } catch (error) {
    console.log(error);
  }
}

const filteredProjects = computed(() => {
  const query = projectName.value.toLowerCase();
  if (!query) return allProjects.value;

  return allProjects.value.filter((project) =>
    project.name.toLowerCase().includes(query),
  );
});

async function addSession() {
  let projectId = null;

  if (projectName.value) {
    try {
      const response = await API.get(`projects`, {
        params: { name: projectName.value },
      });
      if (response.data && response.data.id) {
        projectId = response.data.id;
      } else {
        const createResponse = await API.post("projects", {
          project: { name: projectName.value },
        });
        projectId = createResponse.data.id;
      }
    } catch (error) {
      console.log(error);
    }
  }

  try {
    await API.post("sessions", {
      session: {
        duration: duration.value * 60,
        description: description.value,
        project_id: projectId,
        start_time: date.value.toISOString(),
      },
    });
    emit("sessionAdded");
    close();
  } catch (error) {
    console.log(error);
  }
}

function close() {
  projectName.value = "";
  description.value = "";
  duration.value = 0;
  date.value = new Date();
  model.value = false;
  emit("closeModal");
}
</script>

<template>
  <TTDrawer
    title="Creating"
    v-model="model"
    kitty="/img/kitties/workingKitty.gif"
    altKitty="working kitty"
    position="height: 150px; margin-top: -100px"
  >
    <template #body>
      <div class="add-session-container">
        <TTAutoComplete
          v-model="projectName"
          :suggestions="filteredProjects"
          optionLabel="name"
          label="Project name"
        />

        <TTTextInput label="Description" v-model="description" />

        <TTNumberInput
          v-model="duration"
          label="Duration"
          suffix=" min"
          :min="0"
        />

        <TTDatePicker v-model="date" />

        <TTTextButton
          @click="addSession"
          variant="light-version"
          text="Save"
        ></TTTextButton>
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.add-session-container {
  display: flex;
  align-items: center;
  flex-direction: column;
  width: 100%;
  padding: 0 var(--gap-1);
  gap: var(--gap-3);
  margin-top: var(--gap-2);
}
</style>
