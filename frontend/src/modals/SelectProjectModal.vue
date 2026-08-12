<script setup>
import { ref, onMounted } from "vue";
import API from "@/helper/api.js";

const props = defineProps({
  initialSelection: {
    type: String,
    default: "all projects",
  },
});
const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["closeModal", "selectProject", "projectsChanged"]);

const projects = ref([]);
const tempSelectedProject = ref(props.initialSelection);
const editingProjectId = ref(null);
const editProjectName = ref("");
const deletingProjectId = ref(null);

async function fetchProjects() {
  try {
    const response = await API.get("projects");
    projects.value = response.data;
  } catch (error) {
    console.log(error);
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
  if (!editProjectName.value || !editingProjectId.value) return;

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

    cancelEdit();
  } catch (error) {
    console.log(error);
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

    cancelDelete();
  } catch (error) {
    console.log(error);
  }
}

onMounted(() => {
  fetchProjects();
});
</script>

<template>
  <TTDrawer
    title="Select project"
    v-model="model"
    kitty="/img/kitties/workingKitty.gif"
    altKitty="working kitty"
    position="height: 150px; margin-top: -100px; padding: 0 5px"
  >
    <template #body>
      <div class="select-project-container">
        <ul class="project-list">
          <li
            @click="tempSelectedProject = 'all projects'"
            :class="{ selected: tempSelectedProject === 'all projects' }"
            class="all-projects-li"
          >
            all projects
          </li>
          <li v-for="project in projects" :key="project.id" class="project-li">
            <div v-if="editingProjectId === project.id" class="edit-container">
              <input v-model="editProjectName" class="edit-input" />
              <div class="edit-icons">
                <i class="pi pi-check" @click="saveEdit"></i>
                <i class="pi pi-times" @click="cancelEdit"></i>
              </div>
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
                <i
                  class="pi pi-trash"
                  @click="askConfirmDelete(project.id)"
                ></i>
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
  align-items: center;
  flex-direction: column;
  width: 100%;
  padding: 0 var(--gap-1);
  gap: var(--gap-3);
  margin-top: var(--gap-2);

  .project-list {
    list-style: none;
    padding: 0;
    width: min(100%, 330px);
    max-height: 40vh;
    margin: 0;
    overflow-y: auto;

    li {
      width: 100%;
      min-height: 38px;
      display: flex;
      align-items: center;
      border-radius: 8px;
      margin-bottom: 5px;
      transition: background-color 0.2s;
      box-sizing: border-box;

      &.all-projects-li {
        padding: 10px;
        cursor: pointer;
        justify-content: center;
        border-bottom: 2px solid #344c61;
        margin-bottom: 10px;

        &:hover {
          background-color: rgba(255, 255, 255, 0.1);
        }

        &.selected {
          background-color: #344c61;
        }
      }

      &.project-li {
        padding: 0;
      }
    }

    .project-item,
    .edit-container,
    .delete-confirm-container {
      display: flex;
      justify-content: space-between;
      align-items: center;
      width: 100%;
      padding: 10px;
      border-radius: 8px;
      box-sizing: border-box;
    }

    .project-item {
      &:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      &.selected {
        background-color: #344c61;
      }

      .project-name {
        cursor: pointer;
        flex-grow: 1;
        word-break: break-all;
      }
    }

    .action-icons,
    .edit-icons,
    .delete-icons {
      i {
        cursor: pointer;
        padding: 4px;
        margin-left: 8px;
        border-radius: 4px;
        flex-shrink: 0;
      }
    }

    .action-icons i:hover {
      color: #fff;
      background-color: rgba(0, 0, 0, 0.2);
    }

    .edit-container {
      background-color: rgba(0, 0, 0, 0.2);

      .edit-input {
        width: 100%;
        flex-grow: 1;
        background: lightgrey;
        color: #2c3e50;
        border: none;
        border-radius: 4px;
        padding: 5px;
        font-family: inherit;
        font-size: 0.95em;
      }
    }

    .delete-confirm-container {
      color: lightgrey;

      .delete-icons i:hover {
        background-color: rgba(0, 0, 0, 0.2);
      }
    }
  }

  .text-button {
    font-size: medium;
    padding: 0 10px;
  }
}
</style>
