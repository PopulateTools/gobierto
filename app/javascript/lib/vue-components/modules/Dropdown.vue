<template>
  <div class="gobierto-vue-dropdown">
    <div
      class="gobierto-vue-dropdown--trigger"
      @click="show"
    >
      <slot name="trigger" />
    </div>

    <div class="gobierto-vue-dropdown--content">
      <transition name="slide">
        <slot v-if="isContentVisible" />
      </transition>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Dropdown',
  data() {
    return {
      isContentVisible: true
    }
  },
  created() {
    this.isContentVisible = window.innerWidth <= 769 ? false : true
  },
  methods: {
    show() {
      this.isContentVisible = !this.isContentVisible
      this.$emit('is-content-visible', this.isContentVisible)
    }
  }
}
</script>
