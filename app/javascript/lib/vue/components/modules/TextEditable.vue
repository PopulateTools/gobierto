<template>
  <div class="gobierto-text-editable">
    <component
      :is="tag"
      contenteditable
      @input="handleInput"
      @focus="handleFocus"
      @keypress.enter.prevent="handleEnterKey"
    >
      <slot />
    </component>
    <i
      v-if="icon"
      class="fas fa-edit"
    />
  </div>
</template>

<script>
export default {
  name: "TextEditable",
  props: {
    tag: {
      type: String,
      default: "p"
    },
    icon: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    handleEnterKey() {
      document.activeElement.blur()
    },
    handleFocus() {
      // assure no white-space remaining
      document.activeElement.textContent = document.activeElement.textContent.trim()

      // https://javascript.info/selection-range
      const range = new Range()
      range.selectNodeContents(document.activeElement)
      document.getSelection().removeAllRanges();
      document.getSelection().addRange(range);
    },
    handleInput({ target }) {
      this.$emit('input', target.innerText);
    }
  }
}
</script>