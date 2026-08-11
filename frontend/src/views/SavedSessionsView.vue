<script setup>
import { ref, computed } from "vue";
import API from "@/helper/api.js";
import SelectProjectModal from "@/modals/SelectProjectModal.vue";
import AddSessionModal from "@/modals/AddSessionModal.vue";
import EditSessionModal from "@/modals/EditSessionModal.vue";

const timeWindowSelection = ref("D");
const projectSelection = ref("all projects");
const selectingProject = ref(false);
const addingSession = ref(false);
const selectButtonKey = ref(0);
const allSessions = ref([]);
const timeDisplay = ref("00 h 00 min");
const sessionsPerPage = ref(10);
const currentPage = ref(0);
const canLoadMore = ref(true);
const isLoadingSessions = ref(true);
const projectNamesCache = ref({});
const isEditModalOpen = ref(false);
const selectedSession = ref(null);
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

function openEditModal(session) {
  selectedSession.value = session;
  isEditModalOpen.value = true;
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
  return session.start_time;
}

function createNewSession() {
  addingSession.value = true;
}

function refreshDataAfterProjectChange() {
  projectNamesCache.value = {};
  fetchSessions(true);
  showProjectTime();
}
</script>

<template>
  <div class="main-container">
    <TTIconButton
      @click="$router.push('/')"
      class="home-button"
      icon="pi pi-clock"
    />
    <div class="time-windows">
      <TTSelectButton
        :modelValue="timeWindowSelection"
        @update:modelValue="handleSelectButtonUpdate"
        :key="selectButtonKey"
        :options="['D', 'W', 'M', 'Y', 'ALL']"
      ></TTSelectButton>
    </div>
    <div v-if="timeWindowSelection !== 'ALL'" class="date-navigation-container">
      <div @click="navigateDate(-1)" class="nav-arrow">
        <i class="pi pi-chevron-left"></i>
      </div>

      <span class="date-navigation-text">{{ dateDisplayString }}</span>

      <div @click="navigateDate(1)" class="nav-arrow">
        <i class="pi pi-chevron-right"></i>
      </div>
    </div>
    <div class="time-container">
      <p class="time-display-text">{{ timeDisplay }}</p>
    </div>
    <TTIconButton
      @click="selectingProject = true"
      class="project-selection-container"
      icon="pi pi-briefcase"
      >{{ projectSelection }}</TTIconButton
    >

    <ul class="session-list-container">
      <li
        v-for="session in allSessions"
        :key="session.id"
        class="session-item"
        @click="openEditModal(session)"
      >
        <div class="left-container">
          <div class="date-box">
            <div class="date-month">
              {{ formatDate(getDisplayDate(session)).month }}
            </div>
            <div class="date-day">
              {{ formatDate(getDisplayDate(session)).day }}
            </div>
          </div>
        </div>

        <div class="session-information-container">
          <div class="session-description">
            {{ session.description || "working hard" }}
          </div>

          <div class="project-name">
            {{
              getProjectNameFromCache(session.project_id) || "important stuff"
            }}
          </div>

          <div class="session-duration">
            {{ formatDuration(session.duration) }}
          </div>
        </div>
      </li>
    </ul>

    <TTTextButton
      v-if="canLoadMore && !isLoadingSessions"
      @click="fetchSessions(false)"
      text="Load More"
      style="margin-bottom: 25px"
    />
  </div>

  <TTIconButton
    @click="createNewSession()"
    icon="pi pi-plus"
    class="add-session-button"
  />

  <SelectProjectModal
    v-if="selectingProject"
    v-model="selectingProject"
    :initialSelection="projectSelection"
    @selectProject="handleProjectSelect"
    @projectsChanged="refreshDataAfterProjectChange"
  />

  <AddSessionModal
    v-model="addingSession"
    @sessionAdded="fetchSessions(true)"
  />

  <EditSessionModal
    v-model="isEditModalOpen"
    :session="selectedSession"
    @sessionUpdated="fetchSessions(true)"
    @sessionDeleted="fetchSessions(true)"
  />
</template>

<style scoped>
.main-container {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  margin-top: 100px;

  .home-button {
    position: fixed;
    left: 2rem;
    top: 2rem;
  }

  .time-windows :deep(.p-togglebutton) {
    width: 66px;
  }

  .date-navigation-container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    margin-top: 10px;
    width: 310px;

    .date-navigation-text {
      color: #2c3e50;
      font-family: "Chakra Petch", sans-serif;
      font-size: 20px;
      min-width: 150px;
      text-align: center;
    }

    .nav-arrow {
      color: #2c3e50;
    }
  }

  .time-container {
    background-color: #344c61;
    display: flex;
    justify-content: center;
    align-items: center;
    width: 330px;
    height: 120px;
    border-radius: 15px;
    margin-bottom: 10px;
    margin-top: 10px;
    box-shadow: 10px 10px 15px rgba(0, 0, 0, 0.2);

    .time-display-text {
      color: lightgrey;
      font-size: xx-large;
      font-family: "Chakra Petch", sans-serif;
      font-weight: 400;
      font-style: normal;
    }
  }

  .project-selection-container {
    display: flex;
    flex-direction: row;
    justify-content: center;
    gap: 10px;
    background-color: #2c3e50;
    border-radius: 10px;
    padding: 0 15px;
    color: lightgrey;
  }

  .session-list-container {
    list-style: none;
    padding: 0;
    width: 330px;
    margin-top: 20px;
    display: flex;
    flex-direction: column;
    gap: 10px;

    .session-item {
      background-color: lightblue;
      border: 2px solid #2c3e50;
      border-radius: 10px;
      padding: 10px 10px;
      display: flex;
      justify-content: center;
      gap: 15px;
      color: #2c3e50;
      font-family: "Chakra Petch", sans-serif;
      cursor: pointer;

      .left-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        width: 65px;
        gap: 7px;

        .date-box {
          background-color: #344c61;
          padding-top: 3px;
          color: lightgrey;
          border-radius: 7px;
          width: 65px;
          height: 65px;
          display: flex;
          flex-direction: column;
          justify-content: center;

          .date-month {
            font-size: small;
          }

          .date-day {
            font-size: x-large;
          }
        }
      }

      .session-information-container {
        display: flex;
        justify-content: center;
        flex-direction: column;
        flex-grow: 1;
        min-width: 0;
        align-items: flex-start;
        text-align: left;
        padding-right: 10px;

        .session-description {
          font-size: medium;
          font-weight: 600;
          color: #2c3e50;
          width: 100%;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          margin-bottom: 2px;
        }

        .project-name {
          font-size: 13px;
          color: #344c61;
          width: 100%;
          margin-bottom: 5px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .session-duration {
          font-size: medium;
          color: #2c3e50;
          width: 100%;
        }
      }
    }
  }
}

.add-session-button {
  position: fixed;
  right: 30px;
  bottom: 30px;
}
</style>
