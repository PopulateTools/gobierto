<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <QueriesCode
      :private-queries="privateQueries"
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
    privateQueries: {
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
