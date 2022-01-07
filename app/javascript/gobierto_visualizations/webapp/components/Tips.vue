<template>
  <div class="pure-g block m_b_3">
    <div
      v-for="(element, i) in labels"
      :key="i"
      class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline"
    >
      <!-- eslint-disable vue/no-v-html -->
      <p
        class="decorator"
        v-html="element"
      />
      <!-- eslint-enable vue/no-v-html -->
    </div>
  </div>
</template>

<script>
export default {
  name: "Tips",
  props: {
    labels: {
      type: Array,
      default: () => []
    },
  },
}
</script>
