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
        search:key="name"
      >
        <template v-slot:default="{ result }">
          <strong>{{ result.name }}</strong>
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
      placeholderLabel: "Escribe el título del indicador o proyecto",
      // random
      numbers:[
  4,
  0,
  1,
  5,
  10,
  3,
  2,
  10,
  2,
  7,
  6,
  5,
  9,
  6,
  4,
  8,
  1,
  0,
  8,
  2,
  3,
  1,
  7,
  1,
  2,
  10,
  10,
  5,
  0,
  8,
  7,
  1,
  3,
  10,
  3,
  7,
  1
],
      countries: [
  "Lesotho",
  "Tanzania",
  "Romania",
  "Albania",
  "Saint Vincent and The Grenadines",
  "Japan",
  "Eritrea",
  "Solomon Islands",
  "Mauritius",
  "Mongolia",
  "Yugoslavia",
  "Iceland",
  "Peru",
  "Gambia",
  "Myanmar",
  "Bangladesh",
  "Ukraine",
  "Maldives",
  "Nepal",
  "Cayman Islands",
  "China",
  "Mauritania",
  "Belarus",
  "Turkmenistan",
  "Chile",
  "Croatia (Hrvatska)",
  "Equatorial Guinea",
  "San Marino",
  "Guinea-Bissau",
  "Chad",
  "Kyrgyzstan",
  "Cameroon",
  "Suriname",
  "South Africa",
  "Algeria",
  "Latvia",
  "Belize"
]
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
