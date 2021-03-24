<template>
  <div class="node-action-line">
    <div class="action-line--header node-list cat--negative">
      <h3>{{ title }}</h3>
      <slot />
    </div>

    <div class="node-project-detail">
      <ProjectNativeFields :model="model" />

      <template v-for="{ id, attributes } in customFields">
        <ProjectCustomFields
          :key="id"
          :attributes="attributes"
        />
      </template>
    </div>
  </div>
</template>

<script>
import ProjectNativeFields from "./ProjectNativeFields";
import ProjectCustomFields from "./ProjectCustomFields";
import { PlansStore } from "../lib/store";

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
    const { show_empty_fields = true } = options;
    const { attributes = {} } = this.model;
    const { name } = attributes

    this.title = name;
    // Expand the META object with the matching values for this project
    this.customFields = meta.reduce((acc, item) => {
      const { uid } = item.attributes;
      const value = attributes[uid];

      // hide "estat" custom_field on purpose (it's a vocabulary also)
      if ((uid !== "estat") && (show_empty_fields || (value && value.length)) ){
        acc.push({
          ...item,
          attributes: { ...item.attributes, value }
        });
      }

      return acc;
    }, []);
  }
};
</script>
