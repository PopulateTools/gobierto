<template>
  <div class="gobierto-table">
    <table />
    <button @click="toggleModal">
      showModal
    </button>
    <div v-show="showModal">
      <p>Modal and checkboxes</p>
      <p>test lint-staged</p>
      <p>test lint-staged</p>
      <p>test lint-staged</p>
      <p>test lint-staged</p>
      <p>test lint-staged</p>
    </div>
  </div>
</template>
<script>
export default {
  name: 'Table',
  props: {
    data: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      showModal: false
    }
  },
  methods: {
    toggleModal() {
      this.showModal = true
    }
  }
}

</script>
