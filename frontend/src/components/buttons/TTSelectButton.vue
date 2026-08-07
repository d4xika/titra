<script setup>
const props = defineProps({
  options: {
    type: Array,
    required: true,
  },
  disabled: {
    type: Boolean,
    default: false,
  },
});

const model = defineModel({ type: String, required: true });
const emit = defineEmits(["update:modelValue"]);
</script>

<template>
  <SelectButton
    :disabled="props.disabled"
    v-model="model"
    :options="props.options"
    @update:modelValue="emit('update:modelValue', $event)"
  >
    <template #option="slotProps">
      <slot name="option" v-bind="slotProps"></slot>
    </template>
  </SelectButton>
</template>

<style scoped>
.p-selectbutton {
  box-shadow: 5px 5px 15px rgba(0, 0, 0, 0.2);
}

:deep(.p-togglebutton) {
  background-color: var(--primary-color) !important;
  border-color: var(--primary-color) !important;
}

:deep(.p-togglebutton-content) {
  color: var(--white) !important;
}

:deep(.p-togglebutton-checked span) {
  background-color: var(--secondary-color) !important;
  color: var(--primary-color) !important;
}
</style>
