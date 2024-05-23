<template>
  <div
    :class="{'dashboards-maker--widget__editing': isEditionMode}"
    class="dashboards-maker--widget"
    @mouseenter="handleMouseover"
    @mouseleave="handleMouseout"
  >
    <slot />
    <div
      v-if="isEditionMode"
      class="dashboards-maker--widget__toolbox"
    >
      <Button
        icon="edit"
        class="dashboards-maker--button__square"
        @click.native="handleClickEdit"
      />
      <Button
        icon="trash"
        class="dashboards-maker--button__square"
        @click.native="handleClickDelete"
      />
    </div>
  </div>
</template>

<script>
import Button from './Button.vue'

export default {
  name: "WidgetEditable",
  components: {
    Button
  },
  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      isToolboxVisible: false
    }
  },
  computed: {
    isEditionMode() {
      return !this.disabled && this.isToolboxVisible
    }
  },
  methods: {
    handleMouseover() {
      if (!this.disable) {
        this.isToolboxVisible = true
      }
    },
    handleMouseout() {
      if (!this.disabled) {
        this.isToolboxVisible = false
      }
    },
    handleClickEdit() {
      this.$emit('edit')
    },
    handleClickDelete() {
      this.$emit('delete')
    },
  }
};
</script>
