<template>
  <div>
    <CodeMirror id="codemirror" />
  </div>
</template>

<script>
import CodeMirror from "./EditorSQL.vue";
export default {
  name: "Data",
  components: {
    CodeMirror,
  },
  data() {
    return {

    }
  }
}
</script>
