<script>
export default {
  name: "circleButton",
  props: {
    icon: {
      type: String,
      default: undefined,
    },
  },
};
</script>

<template>
  <div id="circleButton">
    <svg v-if="this.icon === 'restart'" viewBox="0 -960 960 960">
      <path
        d="M440-122q-121-15-200.5-105.5T160-440q0-66 26-126.5T260-672l57 57q-38 34-57.5 79T240-440q0 88 56 155.5T440-202v80Zm80 0v-80q87-16 143.5-83T720-440q0-100-70-170t-170-70h-3l44 44-56 56-140-140 140-140 56 56-44 44h3q134 0 227 93t93 227q0 121-79.5 211.5T520-122Z"
      />
    </svg>
    <svg v-else-if="this.icon === 'resume'" viewBox="0 -960 960 960">
      <path
        d="M320-200v-560l440 280-440 280Zm80-280Zm0 134 210-134-210-134v268Z"
      />
    </svg>
    <svg v-else-if="this.icon === 'stop'" viewBox="0 -960 960 960">
      <path
        d="M320-640v320-320Zm-80 400v-480h480v480H240Zm80-80h320v-320H320v320Z"
      />
    </svg>
    <svg v-else-if="this.icon === 'pause'" viewBox="0 -960 960 960">
      <path
        d="M520-200v-560h240v560H520Zm-320 0v-560h240v560H200Zm400-80h80v-400h-80v400Zm-320 0h80v-400h-80v400Zm0-400v400-400Zm320 0v400-400Z"
      />
    </svg>
  </div>
</template>

<style scoped>
#circleButton {
  cursor: pointer;
  background-color: #2c3e50;
  width: 40px;
  height: 40px;
  padding: 5px;
  border-radius: 50px;
  align-content: center;
  color: white;
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;
}

#circleButton:hover {
  transform: scale(1.05);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}

svg {
  fill: lightgrey;
}
</style>
