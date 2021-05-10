<template>
  <a
    v-if="hasUrl"
    :href="url"
    target="_blank"
  >
    {{ text }}
  </a>
  <span v-else-if="hasText">
    {{ text }}
  </span>
</template>
<script>
export default {
    name: "TextOrLink",
    props: {
      text: {
        type: String,
        default: ''
      },
      url: {
        type: String,
        default: ''
      }
    },
    computed: {
      hasText(){
        return this.text !== undefined && this.text !== ""
      },
      hasUrl(){
        return this.url !== undefined && this.url !== ""
      }
    }
}
</script>

