<template>
  <div>
    <!-- Filter type: date -->
    <template v-if="filter.type === 'date'">
      <Calendar />
    </template>

    <!-- Filter type: checkbox -->
    <template v-else-if="filter.type === 'vocabulary_options'">
      <BlockHeader
        :title="filter.title"
        see-link
        @select-all="isChecked = !isChecked"
      />
      <Checkbox
        v-for="option in filter.options"
        :id="option.id"
        :key="option.id"
        :title="option.name_translations"
        :checked="isChecked"
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
      isChecked: false
    }
  }
};
</script>
