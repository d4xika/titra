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

<style scoped></style>
