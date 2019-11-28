<template>
  <div>
    <!-- Filter type: date -->
    <template v-if="filter.type === 'range'">
      <Calendar
        :saved-start-date="filter.savedStartDate"
        :saved-end-date="filter.savedEndDate"
        @calendar-change="handleCalendarFilter"
      />
    </template>

    <!-- Filter type: checkbox -->
    <template v-else-if="filter.type === 'vocabulary_options'">
      <BlockHeader
        :title="filter.title"
        :label-alt="isEverythingChecked"
        see-link
        @select-all="handleIsEverythingChecked"
      />
      <Checkbox
        v-for="option in filter.options"
        :id="option.id"
        :key="option.id"
        :title="option.title"
        :checked="option.isOptionChecked"
        :counter="option.counter"
        @checkbox-change="handleCheckboxStatus"
      />
    </template>

    <!-- Filter type: range -->
    <template v-else-if="filter.type === 'numeric'">
      <BlockHeader :title="filter.title" />
      <RangeBars
        :range-bars="
          (filter.histogram || []).map((item, i) => ({
            ...item,
            id: item.bucket || i
          }))
        "
        :min="Math.floor(parseFloat(filter.min))"
        :max="Math.ceil(parseFloat(filter.max))"
        :saved-min="filter.savedMin"
        :saved-max="filter.savedMax"
        :total="parseFloat(filter.count)"
        @range-change="handleRangeFilter"
      />
    </template>
  </div>
</template>

<script>
import Calendar from "./Calendar.vue";
import BlockHeader from "./BlockHeader.vue";
import Checkbox from "./Checkbox.vue";
import RangeBars from "./RangeBars.vue";
import { store } from "../mixins/store";

export default {
  name: "BlockFilter",
  components: {
    Calendar,
    BlockHeader,
    Checkbox,
    RangeBars
  },
  props: {
    filter: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      isEverythingChecked: false
    };
  },
  created() {
    const { activeFiltersSelection } = store.state;

    const { type, options = [], key, max, min } = this.filter;

    if (type === "vocabulary_options" && options.length) {
      options.map(
        d =>
          (d.isOptionChecked =
            activeFiltersSelection && activeFiltersSelection.has(key)
              ? activeFiltersSelection.get(key).get(d.id)
              : false)
      );
    }

    if (
      type === "numeric" &&
      (max !== undefined || min !== undefined) &&
      activeFiltersSelection &&
      activeFiltersSelection.has(key)
    ) {
      const { min: __min__, max: __max__ } = activeFiltersSelection.get(key);

      this.filter.savedMin = __min__;
      this.filter.savedMax = __max__;
    }

    if (
      type === "range" &&
      activeFiltersSelection &&
      activeFiltersSelection.has(key)
    ) {
      const { start, end } = activeFiltersSelection.get(key);

      this.filter.savedStartDate = start;
      this.filter.savedEndDate = end;
    }
  },
  methods: {
    handleIsEverythingChecked() {
      this.isEverythingChecked = !this.isEverythingChecked;
      this.filter.options.map(
        d => (d.isOptionChecked = this.isEverythingChecked)
      );
      this.handleCheckboxFilter();
    },
    handleCheckboxStatus(id, value) {
      const index = this.filter.options.findIndex(d => d.id === id);
      this.filter.options[index].isOptionChecked = value;
      this.handleCheckboxFilter();
    },
    handleCheckboxFilter() {
      const { key, options } = this.filter;
      const checkboxesSelected = new Map();
      options.forEach(({ id, isOptionChecked }) =>
        checkboxesSelected.set(id, isOptionChecked)
      );

      const size = [...checkboxesSelected.values()].filter(Boolean).length;
      // Update the property when all isEverythingChecked
      if (size === options.length) {
        this.isEverythingChecked = true;
      }

      // Update the property when none isEverythingChecked
      if (size === 0) {
        this.isEverythingChecked = false;
      }

      const checkboxFilterFn = attrs =>
        attrs[key].find(d => checkboxesSelected.get(Number(d.id)));

      this.$emit(
        "set-filter",
        size ? checkboxFilterFn : undefined,
        key,
        checkboxesSelected
      );
    },
    handleRangeFilter(min, max) {
      const { key, min: __min__, max: __max__ } = this.filter;
      const rangeFilterFn = attrs => attrs[key] >= min && attrs[key] <= max;

      this.$emit(
        "set-filter",
        Math.floor(min) <= Math.floor(Number(__min__)) &&
          Math.floor(max) >= Math.floor(Number(__max__))
          ? undefined
          : rangeFilterFn,
        key,
        { min, max }
      );
    },
    handleCalendarFilter(start, end) {
      const { key, startKey, endKey } = this.filter;
      const calendarFilterFn = attrs => {
        if (start && end && attrs[startKey] && attrs[endKey]) {
          return !(
            end < new Date(attrs[startKey]) || start > new Date(attrs[endKey])
          );
        } else if (start && !end && attrs[endKey]) {
          return !(start > new Date(attrs[endKey]));
        } else if (!start && end && attrs[startKey]) {
          return !(end < new Date(attrs[startKey]));
        } else {
          return false;
        }
      };

      this.$emit(
        "set-filter",
        !start && !end ? undefined : calendarFilterFn,
        key,
        { start, end }
      );
    }
  }
};
</script>
