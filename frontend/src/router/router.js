import { createWebHistory, createRouter } from "vue-router";
import API from "@/helper/api.js";

const routes = [
  {
    path: "/home",
    name: "home",
    component: () => import("@/views/MainView.vue"),
  },
  {
    path: "/savedSessions",
    name: "savedSessions",
    component: () => import("@/views/SavedSessionsView.vue"),
  },
  {
    path: "/",
    name: "welcome",
    component: () => import("@/views/WelcomeView.vue"),
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else {
      return { top: 0 };
    }
  },
});

let isAuthChecked = false;
let isAuthenticated = false;
let invalidCsrfLogoutPromise = null;

const INVALID_CSRF_MARKERS = [
  "InvalidAuthenticityToken",
  "Can't verify CSRF token authenticity",
];

function matchesInvalidCsrfMarker(value) {
  if (!value) {
    return false;
  }

  const content = typeof value === "string" ? value : JSON.stringify(value);

  return INVALID_CSRF_MARKERS.some((marker) => content.includes(marker));
}

function isInvalidCsrfError(error) {
  if (error?.config?.skipInvalidCsrfHandler) {
    return false;
  }

  if (error?.response?.status !== 422) {
    return false;
  }

  return (
    matchesInvalidCsrfMarker(error.response?.data) ||
    matchesInvalidCsrfMarker(error.response?.request?.responseText) ||
    matchesInvalidCsrfMarker(error.message)
  );
}

export function setAuthStatus(status) {
  isAuthenticated = status;
  if (!status) {
    localStorage.removeItem("user");
    delete API.defaults.headers.common["X-CSRF-Token"];
  }
  isAuthChecked = status;
}

async function logoutAfterInvalidCsrf() {
  if (invalidCsrfLogoutPromise) {
    return invalidCsrfLogoutPromise;
  }

  invalidCsrfLogoutPromise = (async () => {
    try {
      const response = await API.get("csrf", {
        skipInvalidCsrfHandler: true,
      });
      API.defaults.headers.common["X-CSRF-Token"] = response.data.csrf_token;

      await API.put("users/logout", null, {
        skipInvalidCsrfHandler: true,
      });
    } catch {
    } finally {
      setAuthStatus(false);

      if (router.currentRoute.value.name !== "authentication") {
        await router.replace({ name: "authentication" });
      }

      invalidCsrfLogoutPromise = null;
    }
  })();

  return invalidCsrfLogoutPromise;
}

API.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (isInvalidCsrfError(error)) {
      await logoutAfterInvalidCsrf();
    }

    return Promise.reject(error);
  },
);

router.beforeEach(async (to, from, next) => {
  if (!isAuthChecked) {
    try {
      const response = await API.get("users/is_logged_in");
      if (response.data.csrf_token) {
        API.defaults.headers.common["X-CSRF-Token"] = response.data.csrf_token;
      }

      isAuthenticated = response.data.authenticated;
      if (isAuthenticated && response.data.user) {
        localStorage.setItem("user", JSON.stringify(response.data.user));
      } else if (!isAuthenticated) {
        localStorage.removeItem("user");
      }
    } catch (error) {
      isAuthenticated = false;
    }
    isAuthChecked = true;
  }

  if (!isAuthenticated) {
    if (to.path !== "/") {
      next("/");
    } else {
      next();
    }
  } else {
    if (to.path === "/") {
      next("/home");
    } else {
      next();
    }
  }
});

export default router;
