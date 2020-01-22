<template>
  <div>
    <input
      :id="`checkbox-${id}-${seed}`"
      :checked="checked"
      type="checkbox"
      @change="marked = !marked"
    >
    <label
      :for="`checkbox-${id}-${seed}`"
    >
      <div>
        {{ title }}
        <i>({{ counter }})</i>
      </div>
    </label>
  </div>
</template>

<script>
export default {
  name: "Checkbox",
  props: {
    title: {
      type: String,
      default: ""
    },
    id: {
      type: Number,
      default: 0
    },
    checked: {
      type: Boolean,
      default: false
    },
    counter: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      marked: false,
      seed: Math.random().toString(36).substring(7)
    }
  },
  watch: {
    marked(value) {
      this.$emit("checkbox-change", { id: this.id, value })
    },
  }
};
</script>