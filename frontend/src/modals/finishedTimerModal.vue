<script setup>
import { ref, computed } from "vue";
import API from "@/helper/api.js";

const props = defineProps({ id: { type: Number } });
const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["closeModal"]);

const projectName = ref("");
const description = ref("");
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

async function updateProjectInfo() {
  const projectNameString = projectName.value;

  if (!projectNameString) {
    await API.patch(`sessions/${props.id}`, {
      session: {
        project_id: null,
        description: description.value,
      },
    });

    return;
  }

  let projectId = null;

  try {
    const response = await API.get(`projects`, {
      params: { name: projectNameString },
    });
    if (response.data && response.data.id) {
      projectId = response.data.id;
    } else {
      const createResponse = await API.post("projects", {
        project: { name: projectNameString },
      });
      projectId = createResponse.data.id;
    }
  } catch (error) {
    console.log(error);
  }

  await API.patch(`sessions/${props.id}`, {
    session: {
      project_id: projectId,
      description: description.value,
    },
  });
}
</script>

<template>
  <TTDrawer title="Great job! So proud of you!" v-model="model">
    <template #body class="finished-timer-modal">
      <img
        style="height: 150px; margin-top: -100px"
        src="/img/kitties/happyKitty.gif"
        alt="happy kitty"
      />
      <div class="questions-container">
        <TTAutoComplete
          class="autocompleteField"
          v-model="projectName"
          :suggestions="filteredProjects"
          optionLabel="name"
          label="Project name"
        />

        <TTTextInput label="Description" v-model="description" />
        <TTTextButton
          @click="
            updateProjectInfo();
            emit('closeModal');
          "
          variant="lightVersion"
          text="Save"
        ></TTTextButton>
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.questions-container {
  display: flex;
  align-items: center;
  flex-direction: column;
  width: 100%;
  padding: 0 var(--gap-1);
  gap: var(--gap-3);
}
</style>
