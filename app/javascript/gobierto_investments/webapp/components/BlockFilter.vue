<template>
  <div>
    <!-- Filter type: date -->
    <template v-if="filter.type === 'date'">
      <Calendar />
    </template>

    <!-- Filter type: checkbox -->
    <template v-else-if="filter.type === 'vocabulary_options'">
      <BlockHeader :title="filter.title"
see-link @select-all="handleAllChecked" />
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
      <RangeBars :bars="6" />
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
      isChecked: false,
      mapCheckboxStatus: null
    };
  },
  watch: {
    isChecked(newVal) {
      this.mapCheckboxStatus.forEach((value, id) => this.mapCheckboxStatus.set(id, newVal));
    }
  },
  created() {
    this.mapCheckboxStatus = new Map();

    if (this.filter.type === "vocabulary_options") {
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
    handleAllChecked() {
      this.isChecked = !this.isChecked;
      // To allow the watcher updates
      this.$nextTick(() => this.sendEvent());
    },
    handleCheckboxStatus(id, value) {
      this.mapCheckboxStatus.set(id, value);
      this.sendEvent();
    },
    sendEvent() {
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

      // TODO: solo apra checkboxes de momento
      this.$emit("set-filter", checkboxesSelected.length ? checkboxFilterFn : undefined);
    }
  }
};
</script>
