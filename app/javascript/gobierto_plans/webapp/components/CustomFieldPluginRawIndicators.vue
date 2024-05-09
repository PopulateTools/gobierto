<template>
  <div class="tablerow">
    <template v-for="indicator in indicators">
      <div
        :key="indicator"
        class="tablerow__item"
      >
        <div class="tablerow__item-title">
          {{ indicator }}
        </div>
        <div class="tablerow__item-table-container">
          <table class="tablerow__item-table">
            <thead class="tablerow__item-table-header">
              <th
                v-for="({ id, name_translations }, index) in noAggColumns"
                :key="id"
              >
                <template v-if="index !== 0">
                  {{ name_translations | translate }}
                </template>
              </th>
            </thead>
            <tr
              v-for="(row, index) in table[indicator]"
              :key="`${row[indicator]}--${index}`"
              class="tablerow__item-table-row"
            >
              <td
                v-for="{ id } in noAggColumns"
                :key="id"
              >
                {{ row[id] }}
              </td>
            </tr>
          </table>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { translate } from '../../../lib/vue/filters';
import { groupBy } from '../lib/helpers';

export default {
  name: "CustomFieldPluginRawIndicators",
  filters: {
    translate
  },
  props: {
    attributes: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      value: [],
      table: {},
      noAggColumns: []
    };
  },
  computed: {
    indicators() {
      return Object.keys(this.table);
    },
  },
  created() {
    const {
      value,
      options: { configuration: { plugin_configuration: { columns } = {} } = {} } = {}
    } = this.attributes;
    this.value = value;

    // first column is the aggregator, the rest of columns will make the table
    const [{ id: aggKey }, ...noAggColumns ] = columns
    this.noAggColumns = noAggColumns

    if (value) {
      // creates as many tables as indicators there are
      const data = groupBy(value, aggKey);

      // sort by date column if exists
      const dateColumnIndex = noAggColumns.findIndex(({ id }) => id === 'date')
      if (dateColumnIndex > -1) {
        // move the column 'date' to the beginning of the list
        noAggColumns.unshift(noAggColumns.splice(dateColumnIndex, 1)[0]);

        for (const key in data) {
          if (Object.prototype.hasOwnProperty.call(data, key)) {
            data[key] = (data[key] || []).sort(({ date: a }, { date: b }) => a < b)
          }
        }
      }

      this.table = data;
    }
  }
};
</script>
