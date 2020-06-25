<template>
  <div>
    <template v-for="{ id, component, config } in availablePlugins">
      <component
        :is="component"
        :key="id"
        :config="config"
      />
    </template>
  </div>
</template>

<script>
const PluginIndicators = () => import("./PluginIndicators");
const PluginRawIndicators = () => import("./PluginRawIndicators");
const PluginHumanResources = () => import("./PluginHumanResources");
const PluginBudgets = () => import("./PluginBudgets");

const AVAILABLE_PLUGINS = [
  {
    id: "budgets",
    component: PluginBudgets
  },
  {
    id: "human_resources",
    component: PluginHumanResources
  },
  {
    id: "indicators",
    component: PluginIndicators
  },
  {
    id: "raw_indicators",
    component: PluginRawIndicators
  }
];

export default {
  name: "ProjectPlugins",
  props: {
    plugins: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      availablePlugins: []
    }
  },
  created() {
    this.activatePlugins(this.plugins);
  },
  methods: {
    activatePlugins(plugins) {
      const keys = Object.keys(plugins);

      // filter the plugins selected from the all available, adding its configuration
      this.availablePlugins = AVAILABLE_PLUGINS.reduce((acc, item) => {
        const { id } = item;

        if (keys.includes(id)) {
          acc.push({ ...item, config: plugins[id] });
        }

        return acc;
      }, []);
    },
  }
};
</script>
