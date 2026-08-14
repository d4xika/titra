<script setup>
import { ref, computed } from "vue";
import API from "@/helper/api.js";
import { useTTToast } from "@/helper/useTTToast.js";

const props = defineProps({ id: { type: Number } });
const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["closeModal"]);
const toast = useTTToast();

const projectName = ref("");
const description = ref("");
const allProjects = ref([]);

loadProjects();

async function loadProjects() {
  try {
    const response = await API.get("projects");
    allProjects.value = response.data;
  } catch (error) {
    toast.apiError(error, "Could not load projects.");
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
  try {
    const projectNameString = projectName.value;
    let projectId = null;

    if (projectNameString) {
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
    }

    await API.patch(`sessions/${props.id}`, {
      session: {
        project_id: projectId,
        description: description.value,
      },
    });

    projectName.value = "";
    description.value = "";
    toast.success("Session details saved.");
    emit("closeModal");
  } catch (error) {
    toast.apiError(error, "Could not save the session details.");
  }
}
</script>

<template>
  <TTDrawer
    title="Great job!"
    v-model="model"
    kitty="/img/kitties/happyKitty.gif"
    altKitty="happy kitty"
    position="height: 9.5rem; margin-top: -6.25rem"
  >
    <template #body class="finished-timer-modal">
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
          @click="updateProjectInfo"
          variant="light-version"
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
  margin-top: var(--gap-2);
}
</style>
