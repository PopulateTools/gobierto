<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <Queries
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :is-user-logged="isUserLogged"
    />
  </div>
</template>
<script>
import Queries from "./../commons/Queries.vue";

export default {
  name: "QueriesTab",
  components: {
    Queries
  },
  props: {
    privateQueries: {
      type: Array,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    },
    isUserLogged: {
      type: Boolean,
      default: false
    }
  }
}
</script>
