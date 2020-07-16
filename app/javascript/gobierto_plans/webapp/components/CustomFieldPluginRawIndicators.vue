<template>
  <div class="tablerow">
    <div class="tablerow__title">
      {{ title | translate }}
    </div>
    <div class="tablerow__data">
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
  </div>
</template>

<script>
import { translate } from "lib/shared";
import { groupBy } from "../lib/helpers";

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
      title: "",
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
      name_translations,
      value,
      options: { configuration: { plugin_configuration: { columns } = {} } = {} } = {}
    } = this.attributes;
    this.title = name_translations;
    this.value = value;

    // first column is the aggregator, the rest of columns will make the table
    const [{ id: aggKey }, ...noAggColumns ] = columns
    this.noAggColumns = noAggColumns

    if (value) {
      // creates as many tables as indicators there are
      const data = groupBy(value, aggKey);

      // sort by date column if exists
      if (noAggColumns.some(({ id }) => id === 'date')) {
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

<style lang="sass" scoped>
.tablerow {
  padding: .5em 0;

  &__title {
    font-size: 14px;
    text-transform: uppercase;
    font-weight: 700;
    margin-bottom: 25px;
  }

  &__data {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-gap: 20px 20px;

    @media screen and (min-width: 768px) {
      grid-gap: 40px 40px;
    }
  }

  &__item {
    background-color: rgba(#D8D8D8, 0.2);
    padding: 0.5em 1em;
    display: flex;

    &-title {
      flex: 0 1 50%;
      padding-right: 5px;
      font-size: 14px;
      font-weight: 600;
      min-width: 25%;
      line-height: 1.2;
    }

    &-table-container {
      flex: 1 0 50%;
      padding-left: 5px;
    }

    &-table {
      text-align: center;
      line-height: 18px;
      color: #4D4D4D;

      th:first-child:not(:last-child),
      td:first-child:not(:last-child) {
        text-align: left;
        padding-left: 0;
        color: rgba(#4D4D4D, 0.5);
        white-space: nowrap;
      }
    }

    &-table-header {
      font-weight: bold;
      color: rgba(#4D4D4D, 0.5);
      border-bottom: 2px solid rgba(#000, 0.2);

      > * {
        border-top: 0;
        font-size: 14px;
        font-weight: bold;
      }
    }

    &-table-row {
      > * {
        font-size: 14px;
        font-weight: normal;
      }

      &:not(:last-child) {
        border-bottom: 1px solid rgba(#000, 0.2);
      }
    }
  }
}
</style>
