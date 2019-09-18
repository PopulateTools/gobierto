<template>
  <div class="investments-home-aside--checkbox">
    <input
      :id="`investments-home-aside--checkbox-${id}`"
      type="checkbox"
      :checked="checked"
    >
    <label :for="`investments-home-aside--checkbox-${id}`">{{ title | translate }}</label>
  </div>
</template>

<script>
import { CommonsMixin } from "../mixins/common.js";

export default {
  name: "Checkbox",
  mixins: [CommonsMixin],
  props: {
    title: {
      type: Object,
      default: () => {}
    },
    id: {
      type: Number,
      default: 0
    },
    checked: {
      type: Boolean,
      default: false
    }
  }
};
</script>