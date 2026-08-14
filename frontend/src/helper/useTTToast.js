import { useToast } from "primevue/usetoast";

const DEFAULT_LIFE = 3500;
const recentMessages = new Map();

function getApiErrorMessage(error, fallback) {
  const data = error?.response?.data;
  const errors = data?.errors;

  if (Array.isArray(errors) && errors.length) return errors.join(", ");
  if (typeof errors === "string") return errors;
  if (typeof data?.message === "string") return data.message;
  if (typeof data?.error === "string") return data.error;

  return fallback;
}

export function useTTToast() {
  const toast = useToast();
  const add = (severity, message, life = DEFAULT_LIFE) => {
    const key = `${severity}:${message}`;
    const now = Date.now();
    if (now - (recentMessages.get(key) || 0) < 1000) return;

    recentMessages.set(key, now);
    toast.add({ severity, message, life });
  };

  return {
    success: (message) => add("success", message),
    info: (message) => add("info", message),
    warn: (message) => add("warn", message),
    error: (message) => add("error", message, 5000),
    apiError: (error, fallback) =>
      add("error", getApiErrorMessage(error, fallback), 5000),
  };
}
