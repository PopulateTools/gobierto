<template>
  <div
    data-testid="table-component"
    class="gobierto-table"
  >
    <div class="gobierto-table__header">
      <slot name="title" />
      <slot
        name="columns"
        :toggle-visibility="toggleVisibility"
      />
    </div>
    <table>
      <thead>
        <th
          v-for="(col, index) in showColumns"
          :key="index"
        >
          {{ col }}
        </th>
      </thead>

      <tbody>
        <tr
          v-for="(item, index) in data"
          :key="index"
        >
          <template
            v-for="(col, _index) in showColumns"
          >
            <template v-if="item[col].type === 'money'">
              <td
                :key="_index"
                :class="item[col].cssClass"
              >
                {{ money(item[col].value) }}
              </td>
            </template>
            <template v-else-if="item[col].type === 'date'">
              <td
                :key="_index"
                :class="item[col].cssClass"
              >
                {{ item[col].value }}
              </td>
            </template>
            <template v-else-if="item[col].type === 'link'">
              <td
                :key="_index"
                :class="item[col].cssClass"
              >
                <a href="#">{{ item[col].value }}</a>
              </td>
            </template>
            <template v-else>
              <td :key="_index">
                {{ item[col] }}
              </td>
            </template>
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>

import { VueFiltersMixin, TableHeaderMixin } from "lib/vue/filters";
export default {
  name: 'Table',
  mixins: [VueFiltersMixin, TableHeaderMixin],
  props: {
    data: {
      type: Array,
      default: () => []
    },
    visibilityColumns: {
      type: Array,
      default: () => []
    },
    orderColumn: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      columns: Object.keys(this.data[0]),
      showColumns: []
    }
  },
  created() {
    this.showColumns = this.visibilityColumns
  },
  methods: {
    toggleVisibility({ id, value }) {
      let pushOrPop = value ? 'push' : 'pop'
      this.showColumns.[pushOrPop](this.columns[this.columns.findIndex((x, index) => index === id)])
      this.$emit('update-show-columns', this.showColumns)
    }
  }
}

</script>
