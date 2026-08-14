<script setup>
const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  min: {
    type: Number,
    default: undefined,
  },
  max: {
    type: Number,
    default: undefined,
  },
  suffix: {
    type: String,
    default: undefined,
  },
});

const model = defineModel({
  type: Number,
  required: false,
});
</script>

<template>
  <FloatLabel variant="on">
    <InputNumber
      v-model="model"
      :min="props.min"
      :max="props.max"
      :suffix="props.suffix"
    />
    <label>{{ props.label }}</label>
  </FloatLabel>
</template>

<style scoped>
.p-floatlabel {
  width: 100% !important;

  &:enabled:focus {
    border: 2px solid var(--secondary-color) !important;
  }

  &:has(.p-inputwrapper-filled) label {
    background-color: var(--primary-color-dark) !important;
  }

  &:has(.p-inputnumber-input:focus) label,
  &:has(.p-inputwrapper-focus) label {
    background-color: var(--secondary-color) !important;
    color: var(--primary-color) !important;
  }
}

:deep(.p-inputnumber) {
  width: 100% !important;
  display: flex;
}

:deep(.p-inputnumber-input) {
  background-color: var(--primary-color-dark) !important;
  border: 1px solid var(--secondary-color) !important;
  padding: var(--gap-2) !important;
  width: 100% !important;
  color: var(--white) !important;

  &:enabled:focus {
    border: 2px solid var(--secondary-color) !important;
  }
}

label {
  background-color: transparent !important;
  color: var(--white) !important;
  padding: 0 var(--gap-1) !important;
}
</style>
