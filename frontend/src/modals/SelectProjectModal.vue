<script setup>
import { ref, onMounted } from "vue";
import API from "@/helper/api.js";
import { useTTToast } from "@/helper/useTTToast.js";

const props = defineProps({
  initialSelection: {
    type: String,
    default: "all projects",
  },
});
const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["closeModal", "selectProject", "projectsChanged"]);
const toast = useTTToast();

const projects = ref([]);
const tempSelectedProject = ref(props.initialSelection);
const editingProjectId = ref(null);
const editProjectName = ref("");
const deletingProjectId = ref(null);
const isLoadingProjects = ref(true);

async function fetchProjects() {
  isLoadingProjects.value = true;

  try {
    const response = await API.get("projects");
    projects.value = response.data;
  } catch (error) {
    toast.apiError(error, "Could not load projects.");
  } finally {
    isLoadingProjects.value = false;
  }
}

function handleSelect() {
  emit("selectProject", tempSelectedProject.value);
  model.value = false;
}

function startEdit(project) {
  editingProjectId.value = project.id;
  editProjectName.value = project.name;
  deletingProjectId.value = null;
}

function cancelEdit() {
  editingProjectId.value = null;
  editProjectName.value = "";
}

async function saveEdit() {
  if (!editProjectName.value.trim() || !editingProjectId.value) {
    toast.warn("Please enter a project name.");
    return;
  }

  try {
    await API.patch(`projects/${editingProjectId.value}`, {
      project: { name: editProjectName.value },
    });

    const index = projects.value.findIndex(
      (p) => p.id === editingProjectId.value,
    );
    if (index !== -1) {
      projects.value[index].name = editProjectName.value;
    }
    if (
      tempSelectedProject.value ===
      projects.value.find((p) => p.id === editingProjectId.value)?.name
    ) {
      tempSelectedProject.value = editProjectName.value;
    }
    emit("projectsChanged");

    toast.success("Project renamed.");
    cancelEdit();
  } catch (error) {
    toast.apiError(error, "Could not rename the project.");
  }
}

function askConfirmDelete(projectId) {
  deletingProjectId.value = projectId;
  editingProjectId.value = null;
}

function cancelDelete() {
  deletingProjectId.value = null;
}

async function deleteProject(projectId) {
  const projectToDelete = projects.value.find((p) => p.id === projectId);

  try {
    await API.delete(`projects/${projectId}`);

    projects.value = projects.value.filter((p) => p.id !== projectId);
    if (tempSelectedProject.value === projectToDelete?.name) {
      tempSelectedProject.value = "all projects";
    }
    emit("projectsChanged");

    toast.success("Project deleted.");
    cancelDelete();
  } catch (error) {
    toast.apiError(error, "Could not delete the project.");
  }
}

onMounted(() => {
  fetchProjects();
});
</script>

<template>
  <TTDrawer
    title="Projects"
    v-model="model"
    kitty="/img/kitties/workingKitty.gif"
    altKitty="working kitty"
    position="height: 9.5rem; margin-top: -6.25rem; padding: 0 var(--gap-1)"
  >
    <template #body>
      <div class="select-project-container">
        <ul class="project-list" :aria-busy="isLoadingProjects">
          <li
            @click="tempSelectedProject = 'all projects'"
            :class="{ selected: tempSelectedProject === 'all projects' }"
            class="all-projects-li"
          >
            all projects
          </li>
          <li class="project-divider" aria-hidden="true"></li>
          <template v-if="isLoadingProjects">
            <li
              v-for="placeholder in 4"
              :key="`project-skeleton-${placeholder}`"
              class="project-skeleton"
              aria-hidden="true"
            >
              <Skeleton
                width="100%"
                height="2.5rem"
                borderRadius="var(--border-radius-1)"
              />
            </li>
          </template>
          <li
            v-else
            v-for="project in projects"
            :key="project.id"
            class="project-li"
          >
            <div v-if="editingProjectId === project.id" class="edit-container">
              <TTTextInput v-model="editProjectName" />
              <div class="edit-icons">
                <i class="pi pi-check" @click="saveEdit"></i>
                <i class="pi pi-times" @click="cancelEdit"></i>
              </div>
              <i class="pi pi-trash" @click="askConfirmDelete(project.id)"></i>
            </div>

            <div
              v-else-if="deletingProjectId === project.id"
              class="delete-confirm-container"
            >
              <span>Delete project?</span>
              <div class="delete-icons">
                <i class="pi pi-check" @click="deleteProject(project.id)"></i>
                <i class="pi pi-times" @click="cancelDelete"></i>
              </div>
            </div>

            <div
              v-else
              class="project-item"
              :class="{ selected: tempSelectedProject === project.name }"
            >
              <span
                class="project-name"
                @click="tempSelectedProject = project.name"
              >
                {{ project.name }}
              </span>
              <div class="action-icons">
                <i class="pi pi-pencil" @click="startEdit(project)"></i>
              </div>
            </div>
          </li>
        </ul>

        <TTTextButton
          class="text-button"
          @click="handleSelect"
          text="Select"
          variant="light-version"
        />
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.select-project-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--gap-3);
  width: 100%;
  padding: 0 var(--gap-1);
  margin-top: var(--gap-2);
  text-align: left;

  .project-list {
    width: min(100%, 20.6rem);
    max-height: 40vh;
    padding: 0;
    margin: 0;
    overflow-y: auto;
    list-style: none;

    li {
      display: flex;
      align-items: center;
      width: 100%;
      min-height: 2rem;
      margin-bottom: var(--gap-1);
      box-sizing: border-box;
      border-radius: var(--border-radius-1);
      transition: background-color 0.2s;
    }

    .all-projects-li {
      justify-content: start;
      padding: var(--gap-2) var(--gap-3);
      cursor: pointer;

      &:hover {
        background-color: var(--white-transparent);
      }

      &.selected {
        background-color: var(--primary-color-dark);
      }
    }

    .project-divider {
      height: 1px;
      min-height: 1px;
      margin: 0 0 var(--gap-2);
      background-color: var(--white-transparent);
      border-radius: 0;
    }

    .project-li {
      padding: 0;
      margin-bottom: var(--gap-2);
    }

    .project-item,
    .edit-container,
    .delete-confirm-container {
      display: flex;
      align-items: center;
      justify-content: space-between;
      width: 100%;
      padding: var(--gap-2) var(--gap-3);
      box-sizing: border-box;
      border-radius: var(--border-radius-1);
    }

    .project-item {
      &:hover {
        background-color: var(--white-transparent);
      }

      &.selected {
        background-color: var(--primary-color-dark);
      }

      .project-name {
        flex-grow: 1;
        cursor: pointer;
        word-break: break-all;
      }
    }

    .action-icons,
    .edit-icons,
    .delete-icons {
      i {
        font-size: var(--font-size-1);
        flex-shrink: 0;
        padding: var(--gap-1);
        margin-left: var(--gap-2);
        border-radius: var(--border-radius-1);
        cursor: pointer;
      }
    }

    .action-icons i:hover,
    .delete-icons i:hover {
      background-color: var(--primary-color-dark);
    }

    .action-icons i:hover {
      color: var(--white);
    }

    .edit-container,
    .delete-confirm-container {
      background-color: var(--primary-color-dark);
    }

    .delete-confirm-container {
      color: var(--white);
    }
  }

  .text-button {
    padding: 0 var(--gap-2);
    font-size: var(--font-size-1-5);
  }
}
</style>
