<template>
  <div class="widget">
    <component
      :is="indicatorTemplate"
      v-if="!isEditing"
      v-bind="indicatorAttrs"
    />
    <form
      v-else
      class="dashboards-maker--widget__form"
      @submit.prevent="handleSubmit"
    >
      <Autocomplete
        :label="selectLabel"
        :placeholder="placeholderLabel"
        :items="autocompleteItems"
        :default-value="defaultValue"
        name="indicator"
        @change="handleChange"
      >
        <template v-slot:default="{ result }">
          <span class="dashboards-maker--widget__form-result">{{ result }}</span>
        </template>
      </Autocomplete>

      <div>
        <label class="dashboards-maker--widget__form-title">{{
          typeLabel
        }}</label>
        <template v-for="({ name }, key) in subtypes">
          <label
            :key="key"
            name="widget-indicator-input-radio"
            class="dashboards-maker--widget__form-label"
          >
            <input
              type="radio"
              name="subtype"
              class="dashboards-maker--widget__form-radio"
              :value="key"
              required
            >
            <span>{{ name() }}</span>
          </label>
        </template>
      </div>
      <div class="dashboards-maker--widget__form-submit">
        <Button>
          {{ saveLabel }}
        </Button>
      </div>
    </form>
  </div>
</template>

<script>
import { Widgets } from "../lib/widgets";
import Button from "./Button";
import { Autocomplete } from "lib/vue-components";

export default {
  name: "WidgetIndicator",
  components: {
    Button,
    Autocomplete
  },
  props: {
    subtype: {
      type: String,
      default: null
    },
    edit: {
      type: Boolean,
      default: false
    },
    widgetsData: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      subtypes: Widgets.INDICATOR.subtypes,
      selectLabel: I18n.t("gobierto_dashboards.select") || "",
      typeLabel: I18n.t("gobierto_dashboards.type") || "",
      saveLabel: I18n.t("gobierto_dashboards.save") || "",
      placeholderLabel: I18n.t("gobierto_dashboards.placeholder") || "",
      id: 0,
      project: ""
    };
  },
  computed: {
    isEditing() {
      return this.edit || !this.indicatorTemplate;
    },
    indicatorTemplate() {
      return this.subtype ? this.subtypes[this.subtype].template : null;
    },
    indicatorAttrs() {
      return {
        title: this.$attrs.data?.name,
        values: this.$attrs.data?.values
      };
    },
    autocompleteItems() {
      return this.widgetsData.map(({ name }) => name)
    },
    defaultValue() {

      return null //this.$attrs.data?.name
    }
  },
  methods: {
    handleChange(value) {
      ({ id: this.id , project: this.project } = this.widgetsData.find(({ name }) => name === value)) || {}
    },
    handleSubmit({ target }) {
      const config = Object.fromEntries(new FormData(target))
      // assign the corresponding data, built from their props
      const data = this.widgetsData.find(({ id, project }) => `${id}---${project}` === `${this.id}---${this.project}`)
      // overwrite indicator value, since the displayed input text diverges from the actual value
      this.$emit("change", { ...config, indicator: `${this.id}---${this.project}`, data });
    }
  }
};
</script>
