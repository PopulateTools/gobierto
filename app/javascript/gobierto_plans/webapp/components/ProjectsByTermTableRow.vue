<template>
  <tr>
    <template v-for="[trId, [, , trVisibility]] in columns">
      <td
        v-if="trVisibility"
        :key="trId"
        class="planification-table__td--alt"
        :class="{ 'is-selected' : marked }"
      >
        <!-- TODO: faltan definir ciertos tipos de plantilla según su type -->
        <template v-if="trId === 'name'">
          <div
            class="planification-table__td-name"
            @click="showProject"
          >
            {{ attributes[trId] }}
          </div>
        </template>
        <template v-else-if="trId === 'progress'">
          {{ attributes[trId] | percent }}
        </template>
        <template v-else>
          {{ attributes[trId] }}
        </template>
      </td>
    </template>
  </tr>
</template>

<script>
import { percent } from "lib/shared";

export default {
  name: "ProjectsByTermTableRow",
  filters: {
    percent
  },
  props: {
    marked: {
      type: Boolean,
      default: false
    },
    projectId: {
      type: String,
      default: ''
    },
    columns: {
      type: Array,
      default: () => []
    },
    attributes: {
      type: Object,
      default: () => {}
    },
  },
  methods: {
    showProject() {
      this.$emit('show-project', this.projectId)
    }
  }
};
</script>
