<script setup>
const props = defineProps({
  icon: {
    type: String,
  },
  variant: {
    type: String,
    default: "square",
    validator: (value) => ["circle", "square"].includes(value),
  },
});
</script>

<template>
  <div class="buttonContainer" :class="`variant-${props.variant}`">
    <i :class="props.icon"></i>
    <slot></slot>
  </div>
</template>

<style scoped>
.buttonContainer {
  background-color: var(--primary-color);
  min-width: var(--font-size-3);
  min-height: var(--font-size-3);
  padding: calc(var(--gap-2) + var(--gap-1));
  display: flex;
  justify-content: center;
  align-items: center;
  color: var(--white);
  cursor: pointer;
  box-shadow: 5px 5px 15px rgba(0, 0, 0, 0.2);
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;

  &.variant-square {
    border-radius: var(--border-radius-2);
  }

  &.variant-circle {
    border-radius: 50%;
  }

  &:hover {
    transform: scale(1.05);
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
  }
}
</style>
