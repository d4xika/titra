<script setup>
const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    default: "text",
  },
});

const model = defineModel({
  type: String,
  required: false,
});
</script>

<template>
  <FloatLabel variant="on">
    <Password
      v-if="props.type === 'password'"
      v-model="model"
      toggleMask
      :feedback="false"
    />
    <InputText v-else v-model="model" />
    <label>{{ props.label }}</label>
  </FloatLabel>
</template>

<style scoped>
.p-floatlabel {
  width: 100% !important;

  &:enabled:focus {
    border: 2px solid var(--secondary-color) !important;
  }

  &:has(.p-inputtext:focus) label {
    background-color: var(--secondary-color) !important;
    color: var(--primary-color) !important;
  }
}

:deep(.p-password) {
  display: flex;

  svg {
    color: var(--white) !important;
  }
}

:deep(.p-inputtext) {
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
  color: var(--white) !important;
}
</style>
