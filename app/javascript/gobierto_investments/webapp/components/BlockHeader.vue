<template>
  <div class="investments-home-aside--block-header">
    <strong>{{ title }}</strong>
    <a
      v-if="seeLink"
      href
    >Tou</a>
  </div>
</template>

<script>
export default {
  name: "BlockHeader",
  props: {
    title: {
      type: String,
      default: ""
    },
    seeLink: {
      type: Boolean,
      default: false
    }
  }
};
</script>