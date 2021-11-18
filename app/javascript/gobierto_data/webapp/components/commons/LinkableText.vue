<template>
  <a
    v-if="hasUrl"
    :href="url"
    target="_blank"
    :style="{'font-size': fontSize}"
  >
    {{ text }}
  </a>
  <span
    v-else-if="hasText"
    :style="{'font-size': fontSize}"
  >
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
      },
      fontSize: {
        type: String,
        default: '1rem'
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

