<script setup>
const props = defineProps({
  icon: {
    type: String,
  },
  variant: {
    type: String,
    default: "square",
    validator: (value) => ["circle", "plain", "square"].includes(value),
  },
  loading: {
    type: Boolean,
    default: false,
  },
  disabled: {
    type: Boolean,
    default: false,
  },
});
</script>

<template>
  <div
    class="buttonContainer"
    :class="[
      `variant-${props.variant}`,
      { disabled: props.disabled || props.loading },
    ]"
    :aria-busy="props.loading"
  >
    <i v-if="props.loading" class="pi pi-spin pi-spinner"></i>
    <i v-else-if="props.icon" :class="props.icon"></i>
    <slot></slot>
  </div>
</template>

<style scoped>
.buttonContainer {
  background-color: var(--primary-color);

  padding: calc(var(--gap-2) + var(--gap-1));
  display: flex;
  justify-content: center;
  align-items: center;
  color: var(--white);
  cursor: pointer;
  box-shadow: var(--gap-1) var(--gap-1) var(--gap-3) rgba(0, 0, 0, 0.2);
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;

  &.disabled {
    opacity: 0.6;
    cursor: not-allowed;
    pointer-events: none;
  }

  &.variant-square {
    border-radius: var(--border-radius-2);
    min-width: var(--font-size-3);
    min-height: var(--font-size-3);
  }

  &.variant-circle {
    border-radius: 50%;
    min-width: var(--font-size-3);
    min-height: var(--font-size-3);
  }

  &.variant-plain {
    min-width: var(--font-size-1);
    min-height: var(--font-size-1);
    padding: 0;
    background-color: transparent;
    border-radius: var(--border-radius-1);
    box-shadow: none;

    &:hover {
      transform: none;
      box-shadow: none;
    }
  }

  &:hover {
    transform: scale(1.05);
    box-shadow: 0 var(--gap-2) var(--gap-3) rgba(0, 0, 0, 0.2);
  }
}
</style>
