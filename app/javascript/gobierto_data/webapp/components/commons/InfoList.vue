<template>
  <div>
    <InfoListElement
      v-for="(item, index) in items"
      :key="index"
      :item="item"
      class="gobierto-data-info-list-element"
    />
  </div>
</template>
<script>
import InfoListElement from "./InfoListElement.vue";
export default {
  name: "Info",
  components: {
    InfoListElement
  },
  props: {
    items: {
      type: Array,
      required: true
    }
  }
}
</script>
