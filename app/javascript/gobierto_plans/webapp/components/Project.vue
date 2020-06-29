<template>
  <div class="node-action-line">
    <div class="action-line--header node-list cat--negative">
      <h3>{{ title }}</h3>
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
      customFields: [],
    };
  },
  created() {
    const META = PlansStore.state.meta;
    const { attributes } = this.model;
    this.title = attributes.name;

    // Expand the META object with the matching values for this project
    this.customFields = META.map(d => ({
      ...d,
      attributes: { ...d.attributes, value: attributes[d.attributes.uid] }
    }));
  }
};
</script>
