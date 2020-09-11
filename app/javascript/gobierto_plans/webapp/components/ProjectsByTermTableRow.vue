<template>
  <li class="planification-table__li">
    <div class="planification-table__li--content">
      <template v-for="[id, { options, visibility }] in columns">
        <div
          v-if="visibility"
          :key="id"
          class="planification-table__td--alt"
          :class="{ 'is-selected' : marked }"
        >
          <slot
            :column="id"
            :options="options"
          />
        </div>
      </template>
    </div>
  </li>
</template>

<script>
export default {
  name: "ProjectsByTermTableRow",
  props: {
    marked: {
      type: Boolean,
      default: false
    },
    columns: {
      type: Array,
      default: () => []
    },
  }
};
</script>
