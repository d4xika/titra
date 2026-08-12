<script setup>
const model = defineModel({ type: Boolean, default: false });
const emit = defineEmits(["closeModal", "reset"]);
</script>

<template>
  <TTDrawer
    title="Reset Timer"
    v-model="model"
    kitty="/img/kitties/sadKitty.gif"
    altKitty="sad kitty"
    position="height: 9.5rem; margin-top: -6.25rem"
  >
    <template #body class="finished-timer-modal">
      <p class="confirmation-text">Are you sure you want to reset?</p>
      <div class="button-container">
        <TTTextButton
          @click="emit('reset', 'closeModal')"
          variant="dark-border-version"
          text="Yes"
        />
        <TTTextButton
          @click="emit('closeModal')"
          variant="light-version"
          text="No"
        />
      </div>
    </template>
  </TTDrawer>
</template>

<style scoped>
.confirmation-text {
  font-size: var(--font-size-1-5);
  margin: 0;
}
.button-container {
  display: flex;
  justify-content: center;
  flex-direction: row;
  margin: var(--gap-3) 0;
  gap: var(--gap-3);
}
</style>
