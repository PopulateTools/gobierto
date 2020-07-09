<template>
  <tr>
    <template v-for="[id, [, , visibility]] in columns">
      <td
        v-if="visibility"
        :key="id"
        class="planification-table__td--alt"
        :class="{ 'is-selected' : marked }"
      >
        <slot :column="id" />
      </td>
    </template>
  </tr>
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
