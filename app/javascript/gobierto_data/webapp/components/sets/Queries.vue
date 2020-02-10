<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <QueriesCode
      :array-queries="arrayQueries"
      :public-queries="publicQueries"
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
    arrayQueries: {
      type: Array,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    }
  }
}
</script>
