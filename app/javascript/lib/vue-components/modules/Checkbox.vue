<template>
  <div class="gobierto-filter-checkbox">
    <input
      :id="`checkbox-${id}-${seed}`"
      :checked="checked"
      type="checkbox"
      class="gobierto-filter-checkbox--input"
      @change="onChange"
    >
    <label
      :for="`checkbox-${id}-${seed}`"
      class="gobierto-filter-checkbox--label"
    >
      <div
        class="gobierto-filter-checkbox--label-title"
      >
        {{ title }}
        <i
          v-if="hasCounter"
          class="gobierto-filter-checkbox--label-counter"
        >({{ counter }})</i>
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
      type: [Number, String],
      default: 0
    },
    checked: {
      type: Boolean,
      default: false
    },
    counter: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      seed: Math.random().toString(36).substring(7)
    }
  },
  computed: {
    hasCounter() {
      return this.counter !== null
    }
  },
  methods: {
    onChange({ target: { checked } }) {
      this.$emit("checkbox-change", { id: this.id, value: checked })
    }
  }
};
</script>
