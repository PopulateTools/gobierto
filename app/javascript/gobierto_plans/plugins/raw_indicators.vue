<template>
  <div
    v-if="config && table"
    class="tablerow"
  >
    <div class="tablerow__title">
      {{ title | translate }}
    </div>
    <div class="tablerow__data">
      <template v-for="indicator in columns">
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
                <th v-if="hasDate" />
                <th v-if="hasObjective">
                  {{ labelObjetive }}
                </th>
                <th v-if="hasReached">
                  {{ labelReached }}
                </th>
              </thead>
              <tr
                v-for="({ id, objective, date, value }, index) in sortByDate(table[indicator])"
                :key="`${id}-${date || index}`"
                class="tablerow__item-table-row"
              >
                <td v-if="hasDate">
                  {{ date }}
                </td>
                <td v-if="hasObjective">
                  {{ objective }}
                </td>
                <td v-if="hasReached">
                  {{ value }}
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
import { VueFiltersMixin } from "lib/shared";

export default {
  name: "RawIndicators",
  mixins: [VueFiltersMixin],
  props: {
    config: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
      table: {},
      labelObjetive: I18n.t("gobierto_plans.plan_types.show.objective") || '',
      labelReached: I18n.t("gobierto_plans.plan_types.show.reached") || '',
    };
  },
  computed: {
    columns() {
      return Object.keys(this.table)
    },
    hasDate() {
      return this.config.data.some(({ date }) => !!date)
    },
    hasObjective() {
      return this.config.data.some(({ objective }) => !!objective)
    },
    hasReached() {
      return this.config.data.some(({ value }) => !!value)
    },
  },
  created() {
    this.title = this.config.title_translations;
    this.table = _.groupBy(this.config.data, 'name');
  },
  methods: {
    sortByDate(arr) {
      return arr.sort(({ date: a }, { date: b }) => a < b)
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
