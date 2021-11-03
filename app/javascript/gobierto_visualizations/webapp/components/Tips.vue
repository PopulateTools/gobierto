<template>
  <div class="pure-g block m_b_3">
    <div
      v-for="[id, label1, label2] in labels"
      :key="id"
      class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline"
    >
      <p class="decorator">
        {{ label1 }}<strong><span :id="id" /></strong>{{ label2 }}<strong>1.000 €</strong>
      </p>
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
