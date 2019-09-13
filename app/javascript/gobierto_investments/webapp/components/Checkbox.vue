<template>
  <div class="investments-home-aside--checkbox">
    <input type="checkbox" :id="`investments-home-aside--checkbox-${item.i}`" />
    <label :for="`investments-home-aside--checkbox-${item.i}`">{{ item.title }}</label>
  </div>
</template>

<script>
export default {
  name: "Checkbox",
  props: {
    item: Object
  }
};
</script>