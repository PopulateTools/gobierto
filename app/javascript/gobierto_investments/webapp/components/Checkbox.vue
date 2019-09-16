<template>
  <div class="investments-home-aside--checkbox">
    <input
      :id="`investments-home-aside--checkbox-${item.i}`"
      type="checkbox"
    >
    <label :for="`investments-home-aside--checkbox-${item.i}`">{{ item.title }}</label>
  </div>
</template>

<script>
export default {
  name: "Checkbox",
  props: {
    item: {
      type: Object,
      default: () => {}
    }
  }
};
</script>