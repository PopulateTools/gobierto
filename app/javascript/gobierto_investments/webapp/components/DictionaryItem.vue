<template>
  <div class="investments-project-main--table-row">
    <div class="investments-project-main--cell-heading">
      {{ name }}
    </div>

    <!-- List type -->
    <div v-if="isList">
      <div
        v-for="(itemList, i) in value"
        :key="i"
        class="investments-project-main--inner-table-row"
      >
        <div>{{ itemList }}</div>
        <div />
      </div>
    </div>

    <!-- Simple type -->
    <div v-else>
      {{ value }}
    </div>
  </div>
</template>

<script>
export default {
  name: "DictionaryItem",
  props: {
    name: String,
    value: [String, Array]
  },
  data() {
    return {
      isList: false
    };
  },
  created() {
    this.isList = this.value && this.value instanceof Array;
  }
};
</script>