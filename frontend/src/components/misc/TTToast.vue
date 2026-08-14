<script setup>
const severityIcons = {
  success: "pi-check-circle",
  info: "pi-info-circle",
  warn: "pi-exclamation-triangle",
  error: "pi-times-circle",
};

function getIcon(severity) {
  return severityIcons[severity] || severityIcons.info;
}

function getMessage(message) {
  return message.message || message.detail || message.summary;
}
</script>

<template>
  <Toast>
    <template #container="{ message, closeCallback }">
      <div class="toasti">
        <div class="left-container">
          <i
            class="pi"
            :class="getIcon(message.severity)"
            aria-hidden="true"
          ></i>
          <p>{{ getMessage(message) }}</p>
        </div>
        <div class="right-container">
          <button
            type="button"
            aria-label="Dismiss notification"
            @click="closeCallback"
          >
            <i class="pi pi-times" aria-hidden="true"></i>
          </button>
        </div>
      </div>
    </template>
  </Toast>
</template>

<style>
.p-toast {
  max-width: 80vw !important;
}

.p-toast .p-toast-message-info {
  background-color: var(--primary-color) !important;
  border: 1px solid var(--white) !important;
}

.p-toast .p-toast-message-success {
  background-color: var(--primary-color) !important;
  border: 1px solid var(--white) !important;
}

.p-toast .p-toast-message-error {
  background-color: var(--red) !important;
  border: 1px solid var(--white) !important;
}

.p-toast .p-toast-message-warn {
  background-color: var(--primary-color-dark) !important;
  border: 1px solid var(--primary-color-transparent) !important;
}
</style>

<style scoped>
.toasti {
  display: flex;
  justify-content: space-between;
  text-align: start;
  padding: var(--gap-3);

  .left-container {
    display: flex;
    align-items: center;
    gap: var(--gap-3);
    color: var(--white) !important;

    p {
      margin: 0;
    }
  }

  .right-container {
    display: flex;
    align-items: center;
    color: var(--white) !important;

    button {
      display: flex;
      padding: var(--gap-1);
      color: inherit;
      background: transparent;
      border: 0;
      cursor: pointer;
    }
  }
}
</style>
