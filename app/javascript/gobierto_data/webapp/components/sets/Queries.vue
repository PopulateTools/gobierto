<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <QueriesCode
      :array-queries="items"
    />
  </div>
</template>

<script>

import QueriesCode from "./../commons/Queries.vue";

export default {
  name: "Queries",
  components: {
    QueriesCode
  },
  props: {
    items: {
      type: Array,
      required: true
    }
  },
  created(){
    console.log(this.items)
  }
}
</script>
