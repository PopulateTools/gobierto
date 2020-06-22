<template>
  <div class="planification-content">
    <section class="level_0">
      <template v-for="(model, index) in json">
        <NodeRoot
          :key="model.id"
          :classes="[
            `cat_${(index % json.length) + 1}`,
            { 'is-root-open': parseInt(activeNode.uid) === index }
          ]"
          :model="model"
          @open-menu-mobile="openMenu = !openMenu"
        />
      </template>
    </section>
  </div>
</template>

<script>
import NodeRoot from "../components/NodeRoot";

export default {
  name: "Home",
  components: {
    NodeRoot
  },
  props: {
    json: {
      type: Array,
      default: () => []
    },
  },
  data() {
    return {
      openMenu: false,
      activeNode: {},
      customFields: {},
      availablePlugins: [],
    };
  },
  methods: {
    setSelection(model) {
      this.activeNode = model;

      // Preprocess custom fields
      const { custom_field_records = [] } = model.attributes;
      if (custom_field_records.length > 0) {
        this.customFields = custom_field_records
      }

      // Activate plugins
      const { plugins_data = {} } = model.attributes;
      if (Object.keys(plugins_data).length) {
        this.availablePlugins = plugins_data
      }
    }
  }
};
</script>
