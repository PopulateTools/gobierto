<template>
  <div class="dashboards-maker--editable">
    <component
      :is="tag"
      contenteditable
      @input="handleInput"
      @focus="handleFocus"
      @keypress.enter.prevent="handleEnterKey"
    >
      <slot />
    </component>
    <i class="fas fa-edit" />
  </div>
</template>

<script>
export default {
  name: "Editable",
  props: {
    tag: {
      type: String,
      default: "p"
    }
  },
  methods: {
    handleEnterKey() {
      document.activeElement.blur()
    },
    handleFocus() {
      document.execCommand('selectAll', false, null);
    },
    handleInput({ target }) {
      this.$emit('input', target.innerText);
    }
  }
}
</script>