<template>
  <div class="node-action-line">
    <div class="action-line--header node-list cat--negative">
      <h3>{{ title }}</h3>
    </div>

    <div class="node-project-detail">
      <ProjectNativeFields :model="model" />

      <ProjectCustomFields
        v-if="hasCustomFields"
        :custom-fields="customFields"
      />

      <ProjectPlugins
        v-if="hasPlugins"
        :plugins="plugins"
      />
    </div>
  </div>
</template>

<script>
import ProjectNativeFields from "./ProjectNativeFields";
import ProjectCustomFields from "./ProjectCustomFields";
import ProjectPlugins from "./ProjectPlugins";

export default {
  name: "Project",
  components: {
    ProjectNativeFields,
    ProjectCustomFields,
    ProjectPlugins
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    },
    customFields: {
      type: Array,
      default: () => []
    },
    plugins: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
    };
  },
  computed: {
    hasPlugins() {
      return !!Object.keys(this.plugins).length
    },
    hasCustomFields() {
      return !!this.customFields.length
    },
  },
  created() {
    const { attributes: { name } } = this.model;
    this.title = name;
  }
};
</script>
