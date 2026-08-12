<script setup>
const props = defineProps({
  label: {
    type: String,
    default: "Date",
  },
});

const model = defineModel({
  type: Date,
  default: null,
});

function updateDate(selectedDate) {
  if (selectedDate && model.value) {
    selectedDate.setHours(
      model.value.getHours(),
      model.value.getMinutes(),
      model.value.getSeconds(),
      model.value.getMilliseconds(),
    );
  }

  model.value = selectedDate;
}
</script>

<template>
  <DatePicker
    :modelValue="model"
    @update:modelValue="updateDate"
    showIcon
    dateFormat="dd/mm/yy"
    :placeholder="props.label"
    class="date-picker"
  />
</template>

<style>
.p-datepicker-panel {
  font-family: "Chakra Petch", sans-serif !important;
}

.p-datepicker-header {
  font-family: "Chakra Petch", sans-serif !important;
}

.p-datepicker-input {
  display: none !important;
}

.p-datepicker-dropdown {
  border: none !important;
  border-radius: var(--border-radius-1) !important;
  background-color: var(--secondary-color) !important;
  color: var(--primary-color) !important;
  padding: var(--gap-2) !important;
}

.p-datepicker-day-selected,
.p-datepicker-month-selected,
.p-datepicker-year-selected {
  background-color: var(--primary-color) !important;
  color: white !important;
}

.p-datepicker-select-year,
.p-datepicker-select-month {
  font-family: "Chakra Petch", sans-serif !important;
  font-size: medium;
}
</style>
