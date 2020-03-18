<template>
  <div class="gobierto-vue-dropdown">
    <div
      class="gobierto-vue-dropdown--trigger"
      @click="show"
    >
      <i
        :class="{'rotate-caret': !isContentVisible }"
        class="fas fa-caret-down"
      />
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
  methods: {
    show() {
      this.isContentVisible = !this.isContentVisible
    }
  }
}
</script>
