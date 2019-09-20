<template>
  <div>
    <!-- Filter type: date -->
    <template v-if="filter.type === 'date'">
      <Calendar @calendar-change="handleCalendarFilter" />
    </template>

    <!-- Filter type: checkbox -->
    <template v-else-if="filter.type === 'vocabulary_options'">
      <BlockHeader :title="filter.title"
:label-alt="isChecked" see-link @select-all="handleIsChecked" />
      <Checkbox
        v-for="option in filter.options"
        :id="option.id"
        :key="option.id"
        :title="option.name_translations"
        :checked="isChecked"
        @checkbox-change="handleCheckboxStatus"
      />
    </template>

    <!-- Filter type: range -->
    <template v-else-if="filter.type === 'numeric'">
      <BlockHeader :title="filter.title" />
      <RangeBars
        :range-bars="(filter.histogram || []).map((item, i) => ({ ...item, id: item.bucket || i }))"
        :min="Math.floor(parseFloat(filter.min))"
        :max="Math.ceil(parseFloat(filter.max))"
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
      isChecked: false
    };
  },
  watch: {
    isChecked(newVal) {
      this.mapCheckboxStatus.forEach((value, id) => this.mapCheckboxStatus.set(id, newVal));
    }
  },
  created() {
    if (this.filter.type === "vocabulary_options") {
      this.mapCheckboxStatus = new Map();
      const { options = [] } = this.filter;
      if (options && options.length) {
        for (let index = 0; index < options.length; index++) {
          const { id } = options[index];
          this.mapCheckboxStatus.set(id, false);
        }
      }
    }
  },
  methods: {
    handleIsChecked() {
      this.isChecked = !this.isChecked;
      // To allow the watcher updates
      this.$nextTick(() => this.handleCheckboxFilter());
    },
    handleCheckboxStatus(id, value) {
      this.mapCheckboxStatus.set(id, value);
      this.handleCheckboxFilter();
    },
    handleCheckboxFilter() {
      const { key } = this.filter;
      const checkboxesSelected = [];

      // Send only the selections
      this.mapCheckboxStatus.forEach((value, id) => {
        if (value) {
          checkboxesSelected.push(id);
        }
      });

      // Update the property when all isChecked
      if (checkboxesSelected.length === this.mapCheckboxStatus.size) {
        this.isChecked = true;
      }

      // Update the property when none isChecked
      if (checkboxesSelected.length === 0) {
        this.isChecked = false;
      }

      const checkboxFilterFn = attrs => attrs[key].find(d => checkboxesSelected.includes(parseFloat(d.id)));

      this.$emit("set-filter", checkboxesSelected.length ? checkboxFilterFn : undefined);
    },
    handleRangeFilter(min, max) {
      const { key, min: _min, max: _max } = this.filter;
      const rangeFilterFn = attrs => attrs[key] >= min && attrs[key] <= max;

      this.$emit(
        "set-filter",
        Math.floor(min) <= Math.floor(parseFloat(_min)) && Math.floor(max) >= Math.floor(parseFloat(_max)) ? undefined : rangeFilterFn
      );
    },
    handleCalendarFilter(start, end) {
      const { key } = this.filter;
      const calendarFilterFn = attrs => {
        if (attrs[key] !== null) {
          if (start && end) {
            return new Date(attrs[key]).getTime() >= start.getTime() && new Date(attrs[key]).getTime() <= end.getTime();
          } else if (start && !end) {
            return new Date(attrs[key]).getTime() >= start.getTime();
          } else if (!start && end) {
            return new Date(attrs[key]).getTime() <= end.getTime();
          } else {
            return false;
          }
        } else {
          return false;
        }
      };

      this.$emit("set-filter", !start && !end ? undefined : calendarFilterFn);
    }
  }
};
</script>
