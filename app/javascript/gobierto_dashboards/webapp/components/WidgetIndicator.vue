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
        :items="widgetsData"
        search-key="name"
        name="indicator"
      >
        <template v-slot:default="{ result }">
          <span class="dashboards-maker--widget__form-result">{{ result.name }}</span>
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
            <span>{{ name }}</span>
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
      selectLabel: "Selecciona el indicador",
      typeLabel: "Tipo",
      saveLabel: "Guardar",
      placeholderLabel: "Escribe el título del indicador o proyecto"
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
    }
  },
  methods: {
    handleSubmit({ target }) {
      this.$emit("change", Object.fromEntries(new FormData(target)));
    }
  }
};
</script>