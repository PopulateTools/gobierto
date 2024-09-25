<template>
  <div class="node-action-line">
    <div class="action-line--header node-list cat--negative">
      <h3>{{ title }}</h3>
      <slot />
    </div>

    <div class="node-project-detail">
      <ProjectNativeFields :model="model" />
      <ProjectCustomFields
        v-for="{ id, attributes } in customFields"
        :key="id"
        :attributes="attributes"
      />
    </div>
  </div>
</template>

<script>
import ProjectNativeFields from './ProjectNativeFields.vue';
import ProjectCustomFields from './ProjectCustomFields.vue';
import { PlansStore } from '../lib/store';

export default {
  name: "Project",
  components: {
    ProjectNativeFields,
    ProjectCustomFields
  },
  props: {
    model: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      title: "",
      customFields: []
    };
  },
  created() {
    const { meta, options } = PlansStore.state;
    const { show_empty_fields = true, show_project_fields } = options;
    const { attributes = {} } = this.model;
    const { name } = attributes

    this.title = name;

    // filter only the columns specified in the configuration
    const fields = show_project_fields ? show_project_fields.map(x => meta.find(y => y.attributes.uid === x)) : meta

    // Expand the META object with the matching values for this project
    this.customFields = fields.reduce((acc, item) => {
      const { uid } = item.attributes;
      const value = attributes[uid];

      if (show_empty_fields || !!value) {
        acc.push({
          ...item,
          attributes: { ...item.attributes, value }
        });
      }

      return acc;
    }, [])
  }
};
</script>
