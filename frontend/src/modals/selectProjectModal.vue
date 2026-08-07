<script setup>
import { ref, onMounted } from "vue";
import API from "@/helper/api.js";

const props = defineProps({
  initialSelection: {
    type: String,
    default: "all projects",
  },
});
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
  <div id="dimmBackground">
    <div id="modal">
      <img
        style="height: 150px; margin-top: -100px"
        src="/img/kitties/workingKitty.gif"
        alt="working kitty"
      />

      <ul style="margin-top: 5px">
        <li
          @click="tempSelectedProject = 'all projects'"
          :class="{ selected: tempSelectedProject === 'all projects' }"
          class="allProjectsLi"
        >
          all projects
        </li>
        <li v-for="project in projects" :key="project.id" class="projectLi">
          <div v-if="editingProjectId === project.id" class="editContainer">
            <input v-model="editProjectName" class="editInput" />
            <div class="editIcons">
              <i class="pi pi-check" @click="saveEdit"></i>
              <i class="pi pi-times" @click="cancelEdit"></i>
            </div>
          </div>

          <div
            v-else-if="deletingProjectId === project.id"
            class="deleteConfirmContainer"
          >
            <span>Delete project?</span>
            <div class="deleteIcons">
              <i class="pi pi-check" @click="deleteProject(project.id)"></i>
              <i class="pi pi-times" @click="cancelDelete"></i>
            </div>
          </div>

          <div
            v-else
            class="projectItem"
            :class="{ selected: tempSelectedProject === project.name }"
          >
            <span
              class="projectName"
              @click="tempSelectedProject = project.name"
            >
              {{ project.name }}
            </span>
            <div class="actionIcons">
              <i class="pi pi-pencil" @click="startEdit(project)"></i>
              <i class="pi pi-trash" @click="askConfirmDelete(project.id)"></i>
            </div>
          </div>
        </li>
      </ul>

      <TTTextButton
        class="textButton"
        @click="handleSelect"
        text="Select"
        variant="lightVersion"
      />
    </div>
  </div>
</template>

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
  top: 0;
}

#modal {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 250px;
  padding-bottom: 30px;
  border-radius: 15px;
  background-color: #2c3e50;
  color: lightgrey;
}

ul {
  list-style: none;
  padding: 0;
  width: 90%;
  margin-bottom: 20px;
  margin-top: 5px;
}

li {
  width: 100%;
  min-height: 38px;
  display: flex;
  align-items: center;
  border-radius: 8px;
  margin-bottom: 5px;
  transition: background-color 0.2s;
  box-sizing: border-box;
}

li.allProjectsLi {
  padding: 10px;
  cursor: pointer;
  justify-content: center;

  border-bottom: 2px solid #344c61;
  margin-bottom: 10px;
}

li.allProjectsLi:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

li.allProjectsLi.selected {
  background-color: #344c61;
}

li.projectLi {
  padding: 0;
}

.projectItem,
.editContainer,
.deleteConfirmContainer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  box-sizing: border-box;
}

.projectItem:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.projectItem.selected {
  background-color: #344c61;
}

.projectName {
  cursor: pointer;
  flex-grow: 1;
  word-break: break-all;
}

.actionIcons i,
.editIcons i,
.deleteIcons i {
  cursor: pointer;
  padding: 4px;
  margin-left: 8px;
  border-radius: 4px;
  flex-shrink: 0;
}

.actionIcons i:hover {
  color: #fff;
  background-color: rgba(0, 0, 0, 0.2);
}

.editContainer {
  background-color: rgba(0, 0, 0, 0.2);
}

.editInput {
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

.deleteConfirmContainer {
  color: lightgrey;
}

.deleteIcons i:hover {
  background-color: rgba(0, 0, 0, 0.2);
}

.textButton {
  font-size: medium;
  padding: 0 10px;
}
</style>
