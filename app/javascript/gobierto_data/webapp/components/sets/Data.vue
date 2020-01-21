<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <SQLEditor id="codemirror" />
  </div>
</template>

<script>
import SQLEditor from "./SQLEditor.vue";
export default {
  name: "Data",
  components: {
    SQLEditor,
  },
  data() {
    return {

    }
  }
}
</script>
