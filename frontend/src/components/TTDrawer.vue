<script setup>
const props = defineProps({
  title: {
    type: String,
    required: true,
  },
});
const model = defineModel({ type: Boolean, default: false });
</script>

<template>
  <Drawer
    v-model:visible="model"
    :header="props.title"
    position="bottom"
    style="height: fit-content"
  >
    <slot name="body"> </slot>
  </Drawer>
</template>

<style>
.p-drawer {
  border-top-left-radius: var(--border-radius-2) !important;
  border-top-right-radius: var(--border-radius-2) !important;
  border: none !important;
  margin: 0 var(--gap-2) !important;
  background-color: var(--primary-color) !important;
  color: var(--white) !important;

  .p-drawer-header {
    padding-bottom: var(--gap-1);
  }

  .p-drawer-content {
    padding-top: var(--gap-2);
  }
}
</style>
