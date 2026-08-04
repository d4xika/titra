<script setup>
import TtIconButton from "../components/buttons/TTIconButton.vue";
import textButton from "@/components/buttons/textButton.vue";
import { ref, computed } from "vue";
import selectProjectModal from "@/modals/selectProjectModal.vue";
import API from "@/helper/api.js";

const timeWindowSelection = ref("D");
const projectSelection = ref("all projects");
const selectingProject = ref(false);
const selectButtonKey = ref(0);
const allSessions = ref([]);
const timeDisplay = ref("00 h 00 min");
const sessionsPerPage = ref(10);
const currentPage = ref(0);
const canLoadMore = ref(true);
const isLoadingSessions = ref(true);
const projectNamesCache = ref({});
const editingSessionId = ref(null);
const editFormData = ref({
  description: "",
  projectName: "",
  duration: "",
  date: null,
});
const currentReferenceDate = ref(new Date());
showProjectTime();
fetchSessions(true);

function handleSelectButtonUpdate(nextVal) {
  if (!nextVal || nextVal === timeWindowSelection.value) {
    selectButtonKey.value++;
    return;
  }
  timeWindowSelection.value = nextVal;

  currentReferenceDate.value = new Date();

  showProjectTime();
  fetchSessions(true);
}

function navigateDate(direction) {
  const newDate = new Date(currentReferenceDate.value);

  switch (timeWindowSelection.value) {
    case "D":
      newDate.setDate(newDate.getDate() + direction);
      break;
    case "W":
      newDate.setDate(newDate.getDate() + direction * 7);
      break;
    case "M":
      newDate.setMonth(newDate.getMonth() + direction);
      break;
    case "Y":
      newDate.setFullYear(newDate.getFullYear() + direction);
      break;
  }

  currentReferenceDate.value = newDate;
  showProjectTime();
  fetchSessions(true);
}

const dateDisplayString = computed(() => {
  const date = new Date(currentReferenceDate.value);
  const lang = "en-US";

  switch (timeWindowSelection.value) {
    case "D":
      return date.toLocaleDateString("de-De", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
    case "W": {
      const startOfWeek = getStartOfWeek(date);
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(endOfWeek.getDate() + 6);
      return `${startOfWeek.getDate()}.${startOfWeek.getMonth() + 1}. - ${endOfWeek.getDate()}.${endOfWeek.getMonth() + 1}.${endOfWeek.getFullYear()}`;
    }
    case "M":
      return date.toLocaleDateString(lang, { month: "long", year: "numeric" });
    case "Y":
      return date.toLocaleDateString(lang, { year: "numeric" });
    default:
      return "";
  }
});

function getStartOfWeek(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  return new Date(d.setDate(diff));
}

function handleProjectSelect(selectedProjectName) {
  projectSelection.value = selectedProjectName;
  selectingProject.value = false;

  showProjectTime();
  fetchSessions(true);
}

function startEditing(session) {
  editingSessionId.value = session.id;

  editFormData.value = {
    description: session.description,
    projectName: getProjectNameFromCache(session.project_id),
    duration: Math.floor(session.duration / 60),
    date: session.start_time ? new Date(session.start_time) : null,
  };
}

function cancelEditing() {
  editingSessionId.value = null;
  editFormData.value = {};
}

async function saveSession() {
  const updates = {
    duration: editFormData.value.duration * 60,
    description: editFormData.value.description,
  };

  if (editFormData.value.date) {
    updates.start_time = new Date(editFormData.value.date).toISOString();
  }

  if (editFormData.value.projectName) {
    let projectId = null;

    try {
      const response = await API.get(`projects`, {
        params: { name: editFormData.value.projectName },
      });
      if (response.data) {
        projectId = response.data.id;
      } else {
        const createResponse = await API.post(`projects`, {
          project: {
            name: editFormData.value.projectName,
          },
        });
        projectId = createResponse.data.id;
      }
    } catch (error) {
      console.log(error);
    }

    updates.project_id = projectId;
  } else {
    updates.project_id = null;
  }

  try {
    await API.patch(`sessions/${editingSessionId.value}`, {
      session: updates,
    });

    cancelEditing();
    await fetchSessions(true);
  } catch (error) {
    console.log(error);
  }
}

async function deleteSession() {
  try {
    await API.delete(`sessions/${editingSessionId.value}`);
  } catch (error) {
    console.log(error);
  }

  allSessions.value = allSessions.value.filter(
    (s) => s.id !== editingSessionId.value,
  );

  cancelEditing();
  await showProjectTime();
}

async function showProjectTime() {
  try {
    let projectId = null;
    if (projectSelection.value !== "all projects") {
      try {
        const response = await API.get(`projects`, {
          params: { name: projectSelection.value },
        });
        if (response.data) {
          projectId = response.data.id;
        }
      } catch (error) {
        console.log(error);
      }
    }

    const queryParams = new URLSearchParams({
      time_window: timeWindowSelection.value,
      date: currentReferenceDate.value.toISOString(),
    });

    if (projectId) {
      queryParams.append("project_id", projectId);
    }

    const response = await API.get(
      `sessions/summary?${queryParams.toString()}`,
    );

    timeDisplay.value = formatDuration(response.data.total_duration);
  } catch (error) {
    console.log(error);
    timeDisplay.value = formatDuration(0);
  }
}

async function fetchSessions(reset = false) {
  if (isLoadingSessions.value && !reset) return;

  isLoadingSessions.value = true;

  if (reset) {
    currentPage.value = 0;
    allSessions.value = [];
    canLoadMore.value = true;
  }

  try {
    const limit = sessionsPerPage.value;
    const offset = currentPage.value * sessionsPerPage.value;

    let projectId = null;
    if (projectSelection.value !== "all projects") {
      try {
        const response = await API.get(`projects`, {
          params: { name: projectSelection.value },
        });
        if (response.data) {
          projectId = response.data.id;
        }
      } catch (error) {
        console.log(error);
      }
    }

    const queryParams = new URLSearchParams({
      limit: limit,
      offset: offset,
      time_window: timeWindowSelection.value,
      date: currentReferenceDate.value.toISOString(),
    });

    if (projectId) {
      queryParams.append("project_id", projectId);
    }

    const response = await API.get(`sessions?${queryParams.toString()}`);
    const data = response.data;

    if (data && data.length > 0) {
      allSessions.value = [...allSessions.value, ...data];
      currentPage.value++;

      if (data.length < limit) {
        canLoadMore.value = false;
      }
    } else {
      canLoadMore.value = false;
    }

    const uniqueProjectIds = [
      ...new Set(data.map((s) => s.project_id).filter((id) => id != null)),
    ];
    uniqueProjectIds.forEach((id) => fetchProjectName(id));
  } catch (error) {
    console.log(error);
    canLoadMore.value = false;
  } finally {
    isLoadingSessions.value = false;
  }
}

function getProjectNameFromCache(projectId) {
  return projectNamesCache.value[projectId];
}

async function fetchProjectName(projectId) {
  if (projectNamesCache.value[projectId]) {
    return;
  }

  try {
    const response = await API.get(`projects/${encodeURIComponent(projectId)}`);
    if (response.data && response.data.name) {
      projectNamesCache.value[projectId] = response.data.name;
    }
  } catch (error) {
    console.log(error);
  }
}

function formatDuration(totalSeconds) {
  if (!totalSeconds) totalSeconds = 0;
  const hours = String(Math.floor(totalSeconds / 3600)).padStart(2, "0");
  const mins = String(Math.floor((totalSeconds % 3600) / 60)).padStart(2, "0");
  return `${hours} h ${mins} min`;
}

function formatDate(dateString) {
  if (!dateString) return { month: "HOT", day: "69" };

  const date = new Date(dateString);

  const monthOptions = { month: "short" };

  const month = date.toLocaleDateString("en-US", monthOptions).toUpperCase();
  const day = date.getDate().toString().padStart(2, "0");

  return { month, day };
}

function getDisplayDate(session) {
  if (editingSessionId.value === session.id && editFormData.value.date) {
    return editFormData.value.date;
  }
  return session.start_time;
}

async function createNewSession() {
  try {
    const session = await API.post("sessions", {
      session: {
        duration: undefined,
        description: undefined,
        project_id: undefined,
        start_time: new Date().toISOString(),
      },
    });

    editingSessionId.value = session.data.id;
    await fetchSessions(true);
  } catch (error) {
    console.log(error);
  }
}

function refreshDataAfterProjectChange() {
  projectNamesCache.value = {};
  fetchSessions(true);
  showProjectTime();
}
</script>

<template>
  <div class="mainContainer">
    <TtIconButton
      @click="$router.push('/')"
      id="backButton"
      icon="pi pi-clock"
    />
    <div class="timeWindows">
      <SelectButton
        :modelValue="timeWindowSelection"
        @update:modelValue="handleSelectButtonUpdate"
        :key="selectButtonKey"
        :options="['D', 'W', 'M', 'Y', 'ALL']"
      ></SelectButton>
    </div>
    <div v-if="timeWindowSelection !== 'ALL'" class="dateNavigationContainer">
      <div @click="navigateDate(-1)" class="navArrow">
        <i class="pi pi-chevron-left"></i>
      </div>

      <span class="dateNavigationText">{{ dateDisplayString }}</span>

      <div @click="navigateDate(1)" class="navArrow">
        <i class="pi pi-chevron-right"></i>
      </div>
    </div>
    <div class="timeContainer">
      <p class="timeDisplayText">{{ timeDisplay }}</p>
    </div>
    <TtIconButton
      @click="selectingProject = true"
      class="projectSelectionContainer"
      icon="pi pi-briefcase"
      >{{ projectSelection }}</TtIconButton
    >

    <ul class="sessionListContainer">
      <li v-for="session in allSessions" :key="session.id" class="sessionItem">
        <div class="leftContainer">
          <div class="dateBox">
            <div class="dateMonth">
              {{ formatDate(getDisplayDate(session)).month }}
            </div>
            <div class="dateDay">
              {{ formatDate(getDisplayDate(session)).day }}
            </div>
          </div>
          <DatePicker
            v-if="editingSessionId === session.id"
            v-model="editFormData.date"
            showIcon
            dateFormat="dd/mm/yy"
          ></DatePicker>
        </div>

        <div class="sessionInformationContainer">
          <div
            v-if="editingSessionId !== session.id"
            class="sessionDescription"
          >
            {{ session.description || "working hard" }}
          </div>
          <div v-else class="sessionDescription">
            <p class="labels">Description</p>
            <InputText v-model="editFormData.description" class="editInput" />
          </div>

          <div v-if="editingSessionId !== session.id" class="projectName">
            {{
              getProjectNameFromCache(session.project_id) || "important stuff"
            }}
          </div>
          <div v-else class="projectName">
            <p class="labels">Project name</p>
            <InputText v-model="editFormData.projectName" class="editInput" />
          </div>

          <div v-if="editingSessionId !== session.id" class="sessionDuration">
            {{ formatDuration(session.duration) }}
          </div>
          <div v-else class="sessionDuration">
            <p class="labels">Duration</p>
            <InputNumber
              v-model="editFormData.duration"
              class="editInput"
              suffix=" min"
              :min="0"
            />
          </div>
        </div>

        <div>
          <div
            v-if="editingSessionId !== session.id"
            @click="startEditing(session)"
            class="actionIcons"
          >
            <i class="pi pi-pencil"></i>
          </div>

          <div class="actionColumn">
            <div v-if="editingSessionId === session.id" class="actionIcons">
              <i class="pi pi-check" @click="saveSession()"></i>
              <i class="pi pi-times" @click="cancelEditing()"></i>
            </div>

            <div v-if="editingSessionId === session.id" class="actionIcons">
              <i
                class="pi pi-trash actionIcon deleteIcon"
                @click="deleteSession(session.id)"
              ></i>
            </div>
          </div>
        </div>
      </li>
    </ul>

    <textButton
      v-if="canLoadMore && !isLoadingSessions"
      @click="fetchSessions(false)"
      text="Load More"
      style="margin-bottom: 25px"
    />
  </div>

  <TtIconButton
    @click="createNewSession()"
    icon="pi pi-plus"
    class="addSessionButton"
  ></TtIconButton>

  <selectProjectModal
    v-if="selectingProject"
    :initialSelection="projectSelection"
    @closeModal="selectingProject = false"
    @selectProject="handleProjectSelect"
    @projectsChanged="refreshDataAfterProjectChange"
  />
</template>

<style scoped>
#backButton {
  position: fixed;
  left: 30px;
  top: 30px;
}

.mainContainer {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  margin-top: 100px;
}

.timeContainer {
  background-color: #344c61;
  display: flex;
  justify-content: center;
  align-items: center;
  width: 330px;
  height: 120px;
  border-radius: 15px;
  margin-bottom: 10px;
  margin-top: 10px;
}

.timeWindows :deep(.p-togglebutton) {
  width: 66px;
}

.timeDisplayText {
  color: lightgrey;
  font-size: xx-large;
  font-family: "Chakra Petch", sans-serif;
  font-weight: 400;
  font-style: normal;
}

.projectSelectionContainer {
  display: flex;
  flex-direction: row;
  justify-content: center;
  gap: 10px;
  background-color: #2c3e50;
  border-radius: 10px;
  padding: 0 15px;
  color: lightgrey;
}

.sessionListContainer {
  list-style: none;
  padding: 0;
  width: 330px;
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.sessionItem {
  background-color: lightblue;
  border: 2px solid #2c3e50;
  border-radius: 10px;
  padding: 10px 10px;
  display: flex;
  justify-content: center;
  gap: 15px;
  color: #2c3e50;
  font-family: "Chakra Petch", sans-serif;
}

.sessionDescription {
  font-size: medium;
  font-weight: 600;
  color: #2c3e50;
  width: 100%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 2px;
}
.sessionDuration {
  font-size: medium;
  color: #2c3e50;
  width: 100%;
}

.dateBox {
  background-color: #344c61;
  padding-top: 3px;
  color: lightgrey;
  border-radius: 7px;
  width: 65px;
  height: 65px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.sessionInformationContainer {
  display: flex;
  justify-content: center;
  flex-direction: column;
  flex-grow: 1;
  min-width: 0;
  align-items: flex-start;
  text-align: left;
  padding-right: 10px;
}

.projectName {
  font-size: 13px;
  color: #344c61;
  width: 100%;
  margin-bottom: 5px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.actionColumn {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: center;
  padding: 5px 0;
  height: 100%;
}

.actionIcons {
  cursor: pointer;
}

.dateMonth {
  font-size: small;
}

.dateDay {
  font-size: x-large;
}

.editInput {
  width: 100%;
  box-sizing: border-box;
  background-color: lightblue;
  color: #2c3e50;
  border: 1px solid #344c61 !important;
  border-radius: 4px;
  display: flex;
  align-items: center;
  height: 30px;
  font-family: inherit;
  font-size: 14px;
  margin-bottom: 5px;
}

.editInput.p-inputnumber {
  padding: 0;
  border: 1px solid #344c61 !important;
}

.editInput :deep(.p-inputtext) {
  background-color: transparent !important;
  box-shadow: none !important;
  color: #2c3e50 !important;
  width: 100%;
  height: 100%;
  padding: 0 8px;
  font-family: inherit;
  font-size: 14px;
}

.editInput:focus-within {
  border: 1px solid #2c3e50 !important;
}

.editInput :deep(.p-inputtext:focus) {
  outline: none !important;
}

.labels {
  margin: 0 0 4px 0;
  font-size: 15px;
  font-weight: bold;
  color: #2c3e50;
  text-align: left;
  display: block;
  width: 100%;
}

.leftContainer {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 65px;
  gap: 7px;
}

.addSessionButton {
  position: fixed;
  right: 30px;
  bottom: 30px;
}

.dateNavigationContainer {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
  width: 310px;
}

.dateNavigationText {
  color: #2c3e50;
  font-family: "Chakra Petch", sans-serif;
  font-size: 20px;
  min-width: 150px;
  text-align: center;
}

.navArrow {
  color: #2c3e50;
}
</style>
