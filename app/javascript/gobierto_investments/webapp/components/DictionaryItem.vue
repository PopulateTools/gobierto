<template>
  <div class="investments-project-main--table-row">
    <div class="investments-project-main--cell-heading">
      {{ name }}
    </div>

    <!-- Table type -->
    <div v-if="type === 'table'">
      <div
        v-for="column in table.columns"
        :key="column"
        class="investments-project-main--inner-table-row"
      >
        <div>{{ value }}</div>
      </div>
    </div>
    <!-- <div v-if="isList">
      <div
        v-for="(itemList, i) in value"
        :key="i"
        class="investments-project-main--inner-table-row"
      >
        <div>{{ itemList }}</div>
        <div />
      </div>
    </div> -->

    <!-- Icon type -->
    <div v-else-if="type === 'icon'">
      <div class="investments-project-main--icon-text">
        <i :class="`fas fa-${icon.name}`" /> <a :href="icon.href">{{ value }}</a>
      </div>
    </div>

    <!-- Highlight type -->
    <div v-else-if="type === 'highlight'">
      <strong class="investments-project-main--strong">{{ value }}</strong>
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
    name: {
      type: String,
      default: ""
    },
    value: {
      type: [String, Array, Number, Object],
      default: ""
    },
    type: {
      type: String,
      default: ""
    },
    icon: {
      type: Object,
      default: () => {}
    },
    table: {
      type: Object,
      default: () => {}
    }
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