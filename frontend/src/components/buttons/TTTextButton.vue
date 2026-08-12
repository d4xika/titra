<script setup>
const props = defineProps({
  text: {
    type: String,
  },
  variant: {
    type: String,
    default: "dark-version",
  },
});
</script>

<template>
  <div class="buttonContainer" :class="`variant-${props.variant}`">
    <p>{{ props.text }}</p>
  </div>
</template>

<style scoped>
.buttonContainer {
  height: 2.5rem;
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: var(--border-radius-2);
  width: fit-content;
  padding: 0 var(--gap-3);
  cursor: pointer;
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;
}

.buttonContainer:hover {
  transform: scale(1.05);
  box-shadow: 0 var(--gap-2) var(--gap-3) rgba(0, 0, 0, 0.2);
}

.variant-light-version {
  background-color: var(--secondary-color);
  color: var(--primary-color);
}

.variant-dark-version {
  background-color: var(--primary-color);
  color: var(--white);
}

.variant-dark-border-version {
  background-color: var(--primary-color);
  color: var(--white);
  border: 1px solid var(--secondary-color);
}
</style>
