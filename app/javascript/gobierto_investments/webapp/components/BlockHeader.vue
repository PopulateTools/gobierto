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
    title: String,
    seeLink: {
      type: Boolean,
      default: false
    }
  }
};
</script>