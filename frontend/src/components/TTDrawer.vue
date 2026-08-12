<script setup>
import TTDivider from "@/components/TTDivider.vue";

const props = defineProps({
  title: {
    type: String,
    required: true,
  },
  kitty: {
    type: String,
    default: undefined,
  },
  altKitty: {
    type: String,
    default: undefined,
  },
  position: {
    type: String,
    default: undefined,
  },
});
const model = defineModel({ type: Boolean, default: false });
</script>

<template>
  <Drawer
    v-model:visible="model"
    position="bottom"
    :header="!$slots.header ? props.title : undefined"
  >
    <template #header v-if="$slots.header || props.kitty">
      <div class="title-container">
        <span class="p-drawer-title">{{ props.title }}</span>
        <TTDivider />
      </div>
      <slot name="header">
        <div class="header-container">
          <img
            v-if="props.kitty"
            class="kitty-image"
            :style="props.position"
            :src="props.kitty"
            :alt="props.altKitty"
          />
        </div>
      </slot>
    </template>
    <slot name="body" />
  </Drawer>
</template>

<style>
.p-drawer {
  height: fit-content !important;
  border-top-left-radius: var(--border-radius-2) !important;
  border-top-right-radius: var(--border-radius-2) !important;
  border: none !important;
  margin: 0 var(--gap-2) !important;
  background-color: var(--primary-color) !important;
  color: var(--white) !important;

  .p-button {
    border: none !important;
    margin-right: 2% !important;
  }

  .title-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
    gap: var(--gap-2);
  }

  .header-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
  }

  .kitty-image {
    z-index: 100;
  }
}
</style>
