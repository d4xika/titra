<script setup>
const props = defineProps({
  text: {
    type: String,
  },
  variant: {
    type: String,
    default: "default",
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

.variant-lightVersion {
  background-color: var(--secondary-color);
  color: var(--primary-color);
}

.variant-default {
  background-color: #2c3e50;
  color: lightgrey;
}
</style>
