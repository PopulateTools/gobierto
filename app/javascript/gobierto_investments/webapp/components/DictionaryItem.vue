<template>
  <div class="investments-project-main--table-row">
    <div class="investments-project-main--cell-heading">
      {{ name }}
    </div>

    <!-- Table type -->
    <div v-if="type === 'table'">
      <div
        v-for="(v, i) in value"
        :key="`${v}-${i}`"
        class="investments-project-main--inner-table-row"
      >
        <div
          v-for="column in table.columns"
          :key="`${column.id}-${v}`"
        >
          <div v-if="column.filter === 'money'">
            {{ v[column.id] | money }}
          </div>
          <div v-else-if="column.filter === 'date'">
            {{ v[column.id] | date }}
          </div>
          <div v-else>
            {{ v[column.id] }}
          </div>
        </div>
      </div>
    </div>

    <!-- Icon type -->
    <div v-else-if="type === 'icon'">
      <template v-for="(v, i) in value">
        <div
          :key="`${v}-${i}`"
          class="investments-project-main--icon-text"
        >
          <i :class="`fas fa-${icon.name}`" /> <a
            :href="v[icon.href]"
            target="_blank"
          >{{ v[icon.title] }}</a>
        </div>
      </template>
    </div>

    <!-- Highlight type -->
    <div v-else-if="type === 'highlight'">
      <strong class="investments-project-main--strong">{{ value }}</strong>
    </div>

    <!-- Link type -->
    <div v-else-if="type === 'link'">
      <a
        :href="value"
        target="_blank"
      >{{ value }}</a>
    </div>

    <!-- Simple type -->
    <div v-else>
      {{ value || "--" }}
    </div>
  </div>
</template>

<script>
import { CommonsMixin } from '../mixins/common.js';

export default {
  name: "DictionaryItem",
  mixins: [CommonsMixin],
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
  }
};
</script>
