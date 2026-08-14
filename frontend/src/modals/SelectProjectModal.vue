<script setup>
import { computed, ref, onMounted } from "vue";
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
const actionMenuProjectId = ref(null);
const isLoadingProjects = ref(true);
const showArchivedProjects = ref(false);

const activeProjects = computed(() =>
  projects.value.filter((project) => !project.archived),
);
const archivedProjects = computed(() =>
  projects.value.filter((project) => project.archived),
);

async function fetchProjects() {
  isLoadingProjects.value = true;

  try {
    const response = await API.get("projects", {
      params: { include_archived: true },
    });
    projects.value = response.data;
    showArchivedProjects.value = projects.value.some(
      (project) =>
        project.archived && project.name === tempSelectedProject.value,
    );
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
  actionMenuProjectId.value = null;
}

function cancelEdit() {
  editingProjectId.value = null;
  editProjectName.value = "";
  actionMenuProjectId.value = null;
}

function toggleActionMenu(projectId) {
  actionMenuProjectId.value =
    actionMenuProjectId.value === projectId ? null : projectId;
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

async function setProjectArchived(project, archived) {
  try {
    await API.patch(`projects/${project.id}`, {
      project: { archived },
    });

    project.archived = archived;
    if (archived) showArchivedProjects.value = true;
    emit("projectsChanged");
    toast.success(archived ? "Project archived." : "Project restored.");
    return true;
  } catch (error) {
    toast.apiError(
      error,
      archived
        ? "Could not archive the project."
        : "Could not restore the project.",
    );
    return false;
  }
}

async function archiveEditedProject(project) {
  if (await setProjectArchived(project, true)) cancelEdit();
}

function askConfirmDelete(projectId) {
  deletingProjectId.value = projectId;
  editingProjectId.value = null;
  actionMenuProjectId.value = null;
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
        <ul class="project-list">
          <li
            @click="tempSelectedProject = 'all projects'"
            :class="{ selected: tempSelectedProject === 'all projects' }"
            class="all-projects-li"
          >
            all projects
          </li>
          <li class="project-divider"></li>
          <template v-if="isLoadingProjects">
            <li
              v-for="placeholder in 4"
              :key="`project-skeleton-${placeholder}`"
              class="project-skeleton"
            >
              <Skeleton
                width="100%"
                height="2.5rem"
                borderRadius="var(--border-radius-1)"
              />
            </li>
          </template>
          <li
            v-for="project in activeProjects"
            v-else
            :key="project.id"
            class="project-li"
          >
            <div v-if="editingProjectId === project.id" class="edit-container">
              <TTTextInput v-model="editProjectName" />
              <div class="action-icons">
                <div class="yes-no-icons">
                  <TTIconButton
                    class="action-icon-button"
                    icon="pi pi-check"
                    variant="plain"
                    @click="saveEdit"
                  />
                  <TTIconButton
                    class="action-icon-button"
                    icon="pi pi-times"
                    variant="plain"
                    @click="cancelEdit"
                  />
                </div>

                <div class="project-actions-menu">
                  <TTIconButton
                    class="action-icon-button"
                    icon="pi pi-ellipsis-v"
                    variant="plain"
                    @click="toggleActionMenu(project.id)"
                  />
                  <div
                    v-if="actionMenuProjectId === project.id"
                    class="project-actions-dropdown"
                  >
                    <TTIconButton
                      class="project-dropdown-action"
                      icon="pi pi-folder"
                      variant="plain"
                      @click="archiveEditedProject(project)"
                    >
                      <span>Archive</span>
                    </TTIconButton>
                    <TTIconButton
                      class="project-dropdown-action delete-action"
                      icon="pi pi-trash"
                      variant="plain"
                      @click="askConfirmDelete(project.id)"
                    >
                      <span>Delete</span>
                    </TTIconButton>
                  </div>
                </div>
              </div>
            </div>

            <div
              v-else-if="deletingProjectId === project.id"
              class="delete-confirm-container"
            >
              <span>Delete project?</span>
              <div class="action-icons">
                <TTIconButton
                  icon="pi pi-check"
                  variant="plain"
                  @click="deleteProject(project.id)"
                />
                <TTIconButton
                  icon="pi pi-times"
                  variant="plain"
                  @click="cancelDelete"
                />
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
                <TTIconButton
                  class="action-icon-button"
                  icon="pi pi-pencil"
                  variant="plain"
                  @click="startEdit(project)"
                />
              </div>
            </div>
          </li>

          <li
            v-if="!isLoadingProjects && archivedProjects.length"
            class="archived-projects-toggle-container"
          >
            <TTIconButton
              class="archived-projects-toggle"
              :icon="
                showArchivedProjects ? 'pi pi-chevron-up' : 'pi pi-chevron-down'
              "
              variant="plain"
              @click="showArchivedProjects = !showArchivedProjects"
            >
              <span>Archived ({{ archivedProjects.length }})</span>
            </TTIconButton>
          </li>

          <template v-if="showArchivedProjects">
            <li
              v-for="project in archivedProjects"
              :key="project.id"
              class="project-li archived-project-li"
            >
              <div
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
                  <TTIconButton
                    class="action-icon-button"
                    icon="pi pi-replay"
                    variant="plain"
                    @click="setProjectArchived(project, false)"
                  />
                </div>
              </div>
            </li>
          </template>
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

    .archived-projects-toggle-container {
      margin-top: var(--gap-2);

      .archived-projects-toggle {
        display: flex;
        flex-direction: row-reverse;
        align-items: center;
        justify-content: space-between;
        width: 100%;
        padding: var(--gap-2) var(--gap-3);
        background-color: var(--primary-color-dark);
        color: var(--white);
        border-radius: var(--border-radius-1);
        font: inherit;
      }
    }

    .archived-project-li {
      opacity: 0.75;
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

    .action-icons {
      display: flex;
      align-items: center;

      .action-icon-button {
        padding: var(--gap-1);

        &:hover {
          background-color: var(--primary-color-dark);
          color: var(--white);
        }
      }

      .yes-no-icons {
        display: flex;
        flex-direction: column;
        padding: 0 var(--gap-1);
      }
    }

    .edit-container,
    .delete-confirm-container {
      background-color: var(--primary-color-dark);
    }

    .project-actions-menu {
      position: relative;
    }

    .project-actions-dropdown {
      position: absolute;
      top: calc(100% + var(--gap-1));
      right: 0;
      z-index: 2;
      display: flex;
      flex-direction: column;
      min-width: 7.5rem;
      padding: var(--gap-1);
      background-color: var(--primary-color-dark);
      border-radius: var(--border-radius-1);
      box-shadow: 0 0.25rem 0.75rem rgba(0, 0, 0, 0.25);

      .project-dropdown-action {
        display: flex;
        align-items: center;
        justify-content: flex-start;
        gap: var(--gap-2);
        width: 100%;
        padding: var(--gap-1) var(--gap-2);
        border-radius: var(--border-radius-1);
        text-align: left;
        font: inherit;

        &:hover {
          background-color: var(--white-transparent);
        }
      }
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
