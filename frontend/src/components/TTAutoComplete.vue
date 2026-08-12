<script setup>
import { ref, onMounted, onBeforeUnmount } from "vue";

const props = defineProps({
  suggestions: {
    type: Array,
    default: () => [],
  },
  optionLabel: {
    type: String,
    required: true,
  },
  label: {
    type: String,
    required: true,
  },
});

const model = defineModel({ type: String, default: "" });

const isOpen = ref(false);
const wrapperRef = ref(null);

const selectOption = (option) => {
  model.value = option[props.optionLabel];
  isOpen.value = false;
};

const handleClickOutside = (event) => {
  if (wrapperRef.value && !wrapperRef.value.contains(event.target)) {
    isOpen.value = false;
  }
};

onMounted(() => document.addEventListener("click", handleClickOutside));
onBeforeUnmount(() =>
  document.removeEventListener("click", handleClickOutside),
);
</script>

<template>
  <FloatLabel variant="on">
    <InputText
      v-model="model"
      @input="isOpen = true"
      @focus="isOpen = true"
      class="input"
    />
    <div class="autocomplete-wrapper" ref="wrapperRef">
      <ul v-show="isOpen && props.suggestions.length > 0" class="dropdown">
        <li
          v-for="(item, index) in props.suggestions"
          :key="index"
          @click="selectOption(item)"
          class="option"
        >
          {{ item[props.optionLabel] }}
        </li>
      </ul>
    </div>
    <label>{{ props.label }}</label>
  </FloatLabel>
</template>

<style scoped>
.p-floatlabel {
  width: 100% !important;

  &:has(.p-inputtext:focus) label {
    background-color: var(--secondary-color) !important;
    color: var(--primary-color) !important;
  }
}

.autocomplete-wrapper {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  pointer-events: none;
}

:deep(.p-inputtext) {
  width: 100%;
  background-color: var(--primary-color-dark) !important;
  border: 1px solid var(--secondary-color) !important;
  padding: var(--gap-2) !important;
  color: var(--white) !important;
  outline: none;
  border-radius: var(--border-radius-1);
  font-size: var(--font-size-1-5) !important;

  &:enabled:focus {
    border: 2px solid var(--secondary-color) !important;
  }
}

label {
  color: var(--white) !important;
}

.dropdown {
  position: absolute;
  top: 8rem;
  left: 0;
  width: 100%;
  background-color: var(--secondary-color);
  border-radius: var(--border-radius-2);
  margin-top: var(--gap-1);
  padding: var(--gap-2) 0;
  margin-bottom: 0;
  list-style: none;
  max-height: 12.5rem;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 var(--gap-1) var(--gap-2) rgba(0, 0, 0, 0.2);
  pointer-events: auto;
}

.option {
  padding: var(--gap-2) var(--gap-3);
  color: var(--primary-color);
  cursor: pointer;
  transition: background-color 0.2s;
}
</style>
