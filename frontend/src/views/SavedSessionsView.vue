<script setup>
import { ref, computed } from "vue";
import API from "@/helper/api.js";
import SelectProjectModal from "@/modals/SelectProjectModal.vue";
import AddSessionModal from "@/modals/AddSessionModal.vue";
import EditSessionModal from "@/modals/EditSessionModal.vue";
import router, { setAuthStatus } from "@/router/router.js";
import { useTTToast } from "@/helper/useTTToast.js";

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
const isLoadingSummary = ref(true);
const projectNamesCache = ref({});
const isEditModalOpen = ref(false);
const selectedSession = ref(null);
const currentReferenceDate = ref(new Date());
const toast = useTTToast();
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
  isLoadingSummary.value = true;

  try {
    let projectId = null;
    if (projectSelection.value !== "all projects") {
      const projectResponse = await API.get(`projects`, {
        params: { name: projectSelection.value },
      });
      if (projectResponse.data) {
        projectId = projectResponse.data.id;
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
    toast.apiError(error, "Could not load the time summary.");
    timeDisplay.value = formatDuration(0);
  } finally {
    isLoadingSummary.value = false;
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
      const projectResponse = await API.get(`projects`, {
        params: { name: projectSelection.value },
      });
      if (projectResponse.data) {
        projectId = projectResponse.data.id;
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
    const data = response.data || [];

    if (data.length > 0) {
      const uniqueProjectIds = [
        ...new Set(data.map((s) => s.project_id).filter((id) => id != null)),
      ];
      const projectResults = await Promise.all(
        uniqueProjectIds.map(fetchProjectName),
      );
      if (projectResults.some((loaded) => !loaded)) {
        toast.warn("Some project names could not be loaded.");
      }

      allSessions.value = [...allSessions.value, ...data];
      currentPage.value++;

      if (data.length < limit) {
        canLoadMore.value = false;
      }
    } else {
      canLoadMore.value = false;
    }
  } catch (error) {
    toast.apiError(error, "Could not load sessions.");
    canLoadMore.value = false;
  } finally {
    isLoadingSessions.value = false;
  }
}

function getProjectNameFromCache(projectId) {
  return projectNamesCache.value[projectId];
}

async function fetchProjectName(projectId) {
  if (projectNamesCache.value[projectId]) return true;

  try {
    const response = await API.get(`projects/${encodeURIComponent(projectId)}`);
    if (response.data && response.data.name) {
      projectNamesCache.value[projectId] = response.data.name;
      return true;
    }
  } catch {
    return false;
  }

  return false;
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

function logout() {
  API.put("users/logout")
    .then(() => toast.success("Logged out."))
    .catch((error) =>
      toast.apiError(error, "The server could not complete logout."),
    )
    .finally(() => {
      setAuthStatus(false);
      router.push({ name: "welcome" });
    });
}
</script>

<template>
  <div class="main-container">
    <TTIconButton
      @click="$router.push({ name: 'home' })"
      class="home-button"
      icon="pi pi-clock"
    />

    <TTIconButton @click="logout" class="logout-button" icon="pi pi-sign-out" />

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

    <div class="time-container" :aria-busy="isLoadingSummary">
      <Skeleton
        v-if="isLoadingSummary"
        width="11rem"
        height="2.75rem"
        borderRadius="var(--border-radius-1)"
      />
      <p v-else class="time-display-text">{{ timeDisplay }}</p>
    </div>

    <TTIconButton
      @click="selectingProject = true"
      class="project-selection-container"
      icon="pi pi-briefcase"
      >{{ projectSelection }}</TTIconButton
    >

    <ul class="session-list-container" :aria-busy="isLoadingSessions">
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

          <TTTag
            :text="getProjectNameFromCache(session.project_id)"
            icon="pi pi-briefcase"
          />

          <div class="session-duration">
            {{ formatDuration(session.duration) }}
          </div>
        </div>
      </li>
      <template v-if="isLoadingSessions && allSessions.length === 0">
        <li
          v-for="placeholder in 4"
          :key="`session-skeleton-${placeholder}`"
          class="session-item-skeleton"
          aria-hidden="true"
        >
          <Skeleton
            width="100%"
            height="5.5rem"
            borderRadius="var(--border-radius-2)"
          />
        </li>
      </template>
    </ul>

    <TTTextButton
      v-if="canLoadMore && !isLoadingSessions"
      @click="fetchSessions(false)"
      text="Load More"
      style="margin-bottom: var(--gap-4)"
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
    @sessionAdded="
      fetchSessions(true);
      showProjectTime();
    "
  />

  <EditSessionModal
    v-model="isEditModalOpen"
    :session="selectedSession"
    @sessionUpdated="
      fetchSessions(true);
      showProjectTime();
    "
    @sessionDeleted="
      fetchSessions(true);
      showProjectTime();
    "
  />
</template>

<style scoped>
.main-container {
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
  margin-top: 6.25rem;

  .home-button {
    position: fixed;
    left: 2rem;
    top: 2rem;
  }

  .logout-button {
    position: fixed;
    right: 2rem;
    top: 2rem;
  }

  .time-windows :deep(.p-togglebutton) {
    width: 4.125rem;
  }

  .date-navigation-container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
    margin-top: var(--gap-2);
    width: 19.375rem;

    .date-navigation-text {
      color: var(--primary-color);
      font-family: "Chakra Petch", sans-serif;
      font-size: var(--font-size-1-5);
      min-width: 9.375rem;
      text-align: center;
    }

    .nav-arrow {
      color: var(--primary-color);
    }
  }

  .time-container {
    background-color: var(--primary-color);
    display: flex;
    justify-content: center;
    align-items: center;
    width: 20.6rem;
    height: 7.5rem;
    border-radius: var(--border-radius-2);
    margin-bottom: var(--gap-2);
    margin-top: var(--gap-2);
    box-shadow: var(--gap-2) var(--gap-2) var(--gap-3) rgba(0, 0, 0, 0.2);

    .time-display-text {
      color: var(--white);
      font-size: var(--font-size-3);
    }
  }

  .project-selection-container {
    display: flex;
    flex-direction: row;
    justify-content: center;
    gap: var(--gap-2);
    background-color: var(--primary-color);
    border-radius: var(--border-radius-2);
    padding: 0 var(--gap-3);
    color: var(--white);
  }

  .session-list-container {
    list-style: none;
    padding: 0;
    width: 20.6rem;
    margin-top: var(--gap-3);
    display: flex;
    flex-direction: column;
    gap: var(--gap-2);

    .session-item-skeleton :deep(.p-skeleton) {
      background: var(--primary-color-transparent);
    }

    .session-item {
      background-color: var(--secondary-color-light);
      border: 1px solid var(--primary-color-transparent);
      border-radius: var(--border-radius-2);
      display: flex;
      justify-content: center;
      align-items: center;
      gap: var(--gap-1);
      color: var(--primary-color);
      cursor: pointer;
      box-shadow: var(--gap-1) var(--gap-1) var(--gap-2) rgba(0, 0, 0, 0.2);

      .date-box {
        display: flex;
        flex-direction: column;
        justify-content: center;
        background-color: var(--primary-color);
        color: var(--white);
        padding: var(--gap-2) var(--gap-3-5) var(--gap-1) var(--gap-3-5);
        margin: var(--gap-2-5);
        border-radius: var(--border-radius-1-5);

        .date-month {
          font-size: var(--font-size-1);
        }

        .date-day {
          font-size: var(--font-size-2);
        }
      }

      .session-information-container {
        display: flex;
        justify-content: center;
        flex-direction: column;
        flex-grow: 1;
        text-align: left;
        gap: var(--gap-1);
        min-width: 0;

        .session-description {
          font-size: var(--font-size-1);
          color: var(--primary-color);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .session-duration {
          font-size: var(--font-size-1-5);
          color: var(--primary-color);
          font-weight: 700;
        }
      }

      &:hover {
        transform: scale(1.01);
        transition: transform 0.3s;
      }
    }
  }
}

.add-session-button {
  position: fixed;
  right: var(--gap-4);
  bottom: var(--gap-4);
}
</style>
