<script setup>
import { ref, computed, watch } from "vue";
import API from "@/helper/api.js";

const props = defineProps({
  session: {
    type: Object,
    default: null,
  },
});

const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["sessionUpdated", "sessionDeleted", "closeModal"]);

const projectName = ref("");
const description = ref("");
const duration = ref(0);
const date = ref(null);
const allProjects = ref([]);
const confirmingDelete = ref(false);

loadProjects();

async function loadProjects() {
  try {
    const response = await API.get("projects");
    allProjects.value = response.data;
  } catch (error) {
    console.log(error);
  }
}

watch(
  () => props.session,
  (newSession) => {
    confirmingDelete.value = false;

    if (newSession) {
      description.value = newSession.description || "";
      duration.value = Math.floor((newSession.duration || 0) / 60);
      date.value = newSession.start_time
        ? new Date(newSession.start_time)
        : null;
      if (newSession.project_id) {
        fetchProjectName(newSession.project_id);
      } else {
        projectName.value = "";
      }
    }
  },
  { immediate: true },
);

async function fetchProjectName(projectId) {
  try {
    const response = await API.get(`projects/${encodeURIComponent(projectId)}`);
    if (response.data && response.data.name) {
      projectName.value = response.data.name;
    }
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

async function saveSession() {
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
    await API.patch(`sessions/${props.session.id}`, {
      session: {
        duration: duration.value * 60,
        description: description.value,
        project_id: projectId,
        start_time: date.value ? date.value.toISOString() : null,
      },
    });
    emit("sessionUpdated");
    close();
  } catch (error) {
    console.log(error);
  }
}

async function deleteSession() {
  try {
    await API.delete(`sessions/${props.session.id}`);
    emit("sessionDeleted");
    close();
  } catch (error) {
    console.log(error);
  }
}

function confirmDelete() {
  confirmingDelete.value = true;
}

function cancelDelete() {
  confirmingDelete.value = false;
}

function close() {
  confirmingDelete.value = false;
  model.value = false;
  emit("closeModal");
}
</script>

<template>
  <TTDrawer
    title="Editing"
    v-model="model"
    kitty="/img/kitties/workingKitty.gif"
    altKitty="working kitty"
    position="height: 9.5rem; margin-top: -6.25rem; padding: 0 var(--gap-1)"
  >
    <template #body>
      <div class="edit-session-container">
        <div class="date-picker-container">
          <TTDatePicker v-model="date" />
          <p class="date-display">
            {{
              date.toLocaleDateString("en-US", {
                month: "long",
                day: "numeric",
                year: "numeric",
              })
            }}
          </p>
        </div>

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

        <div v-if="confirmingDelete" class="delete-confirmation">
          <span>Delete this session?</span>
          <div class="actions">
            <TTTextButton
              @click="deleteSession"
              variant="dark-border-version"
              text="Yes"
            />
            <TTTextButton
              @click="cancelDelete"
              variant="light-version"
              text="No"
            />
          </div>
        </div>
        <div v-else class="actions">
          <TTTextButton
            @click="confirmDelete"
            variant="dark-border-version"
            text="Delete"
          ></TTTextButton>
          <TTTextButton
            @click="saveSession"
            variant="light-version"
            text="Save"
          ></TTTextButton>
        </div>
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.edit-session-container {
  display: flex;
  align-items: center;
  flex-direction: column;
  width: 100%;
  padding: 0 var(--gap-1);
  gap: var(--gap-3);

  .date-picker-container {
    display: flex;
    flex-direction: row;
    align-items: center;
    align-self: flex-start;
    gap: var(--gap-3);
    padding-bottom: var(--gap-2);

    .date-display {
      font-size: var(--font-size-1-5);
      color: var(--white);
      margin: 0;
    }
  }

  .delete-confirmation {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--gap-1);
  }

  .actions {
    display: flex;
    gap: var(--gap-2);
    width: 100%;
    justify-content: center;
    margin-top: var(--gap-1);
  }
}
</style>
