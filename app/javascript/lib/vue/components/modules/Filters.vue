<template>
  <div class="gobierto-filters">
    <transition
      name="fade"
      mode="out-in"
    >
      <span
        v-if="isDirty"
        class="gobierto-filters--clear"
        @click="clear"
      >{{ labelClear }}</span>
    </transition>

    <div
      v-for="filter in filters"
      :key="filter.key"
    >
      <!-- Filter type: calendar -->
      <template v-if="filter.type === 'date'">
        <Dropdown @is-content-visible="filter.rotate = !filter.rotate">
          <template #trigger>
            <BlockHeader
              :rotate="filter.rotate"
              :title="filter.title"
            />
          </template>
          <Calendar
            :saved-start-date="filter.savedStartDate"
            :saved-end-date="filter.savedEndDate"
            @calendar-change="e => handleCalendarFilterStatus({ ...e, filter })"
          />
        </Dropdown>
      </template>

      <!-- Filter type: checkbox -->
      <template v-else-if="filter.type === 'vocabulary_options'">
        <Dropdown @is-content-visible="filter.rotate = !filter.rotate">
          <template #trigger>
            <BlockHeader
              :rotate="filter.rotate"
              :title="filter.title"
              :label-alt="filter.isEverythingChecked"
              see-link
              @select-all="e => handleIsEverythingChecked({ ...e, filter })"
            />
          </template>
          <div>
            <Checkbox
              v-for="option in filter.options"
              :id="option.id"
              :key="option.id"
              :title="option.title"
              :checked="option.isOptionChecked"
              :counter="option.counter"
              @checkbox-change="e => handleCheckboxStatus({ ...e, filter })"
            />
          </div>
        </Dropdown>
      </template>

      <!-- Filter type: numeric range -->
      <template v-else-if="filter.type === 'numeric'">
        <Dropdown @is-content-visible="filter.rotate = !filter.rotate">
          <template #trigger>
            <BlockHeader
              :rotate="filter.rotate"
              :title="filter.title"
            />
          </template>
          <RangeBars
            :histogram="
              (filter.histogram || []).map((item, i) => ({
                ...item,
                id: item.bucket || i
              }))
            "
            :min="Math.floor(+filter.min)"
            :max="Math.ceil(parseFloat(filter.max))"
            :saved-min="filter.savedMin"
            :saved-max="filter.savedMax"
            :total-items="parseFloat(filter.count)"
            @range-change="e => handleRangeFilterStatus({ ...e, filter })"
          />
        </Dropdown>
      </template>
    </div>
  </div>
</template>

<script>
import { ItemsFilterMixin } from "lib/vue/mixins";
import { Checkbox, BlockHeader, Calendar, RangeBars, Dropdown } from "lib/vue/components";

export default {
  name: "Filters",
  components: {
    Checkbox,
    BlockHeader,
    Calendar,
    RangeBars,
    Dropdown
  },
  mixins: [ItemsFilterMixin],
  props: {
    data: {
      type: Array,
      default: () => []
    },
    fields: {
      type: Array,
      default: () => []
    },
    metadata: {
      type: Array,
      default: () => []
    },
    stats: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      labelClear: I18n.t("gobierto_common.vue_components.filters.clear") || "",
      items: this.data
    };
  },
  watch: {
    data: {
      handler(data) {
        this.items = data;
      },
      immediate: true
    },
    subsetItems: {
      handler(items) {
        this.$emit("update", items);
      },
      immediate: true
    }
  },
  created() {
    // items-filter method
    this.createFilters({
      filters: this.fields,
      dictionary: this.metadata,
      stats: this.stats
    });
  },
  methods: {
    clear() {
      // items-filter method
      this.clearFilters();
      this.$emit("clear");
    }
  }
};
</script>
