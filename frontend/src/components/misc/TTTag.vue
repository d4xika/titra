<script setup>
const props = defineProps({
  color: {
    type: String,
    default: "blue",
  },
  text: {
    type: String,
    required: true,
  },
  icon: {
    type: String,
    default: undefined,
  },
});
</script>

<template>
  <div :class="`color-${props.color}`" class="tag">
    <div v-if="props.icon" class="icon-container">
      <i :class="props.icon" class="icon"></i>
    </div>
    <p class="text">{{ props.text || "important stuff" }}</p>
  </div>
</template>

<style scoped>
.tag {
  display: flex;
  align-items: center;
  overflow: hidden;
  word-break: break-word;
  padding: 2px var(--gap-2);
  border-radius: var(--border-radius-1-5);
  width: fit-content;
  font-weight: 600;

  &.color-blue {
    background-color: var(--primary-color-transparent);
    color: var(--primary-color);
  }

  .icon-container {
    display: flex;
    align-items: center;
    justify-content: center;
    margin-right: var(--gap-1);

    .icon {
      font-size: var(--font-size-1);
    }
  }

  .text {
    margin: 0;
    font-size: var(--font-size-1);
  }
}
</style>
