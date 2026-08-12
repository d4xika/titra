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
  height: 40px;
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 10px;
  width: fit-content;
  padding: 0 20px 0 20px;
  cursor: pointer;
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;
}

.buttonContainer:hover {
  transform: scale(1.05);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
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
