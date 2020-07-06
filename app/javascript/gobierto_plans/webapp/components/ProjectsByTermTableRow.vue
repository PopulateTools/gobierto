<template>
  <tr>
    <template v-for="[trId, [, , trVisibility]] in columns">
      <td
        v-if="trVisibility"
        :key="trId"
      >
        <!-- TODO: faltan definir ciertos tipos de plantilla según su type -->
        <template v-if="trId === 'name'">
          <div @click="showProject">
            {{ attributes[trId] }}
          </div>
        </template>
        <template v-else>
          {{ attributes[trId] }}
        </template>
      </td>
    </template>
  </tr>
</template>

<script>
export default {
  name: "ProjectsByTermTableRow",
  props: {
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
