<template>
  <div class="widget">
    <component
      :is="indicator"
      v-if="!edit"
    />
    <form
      v-else
      class="dashboards-maker--widget__form"
    >
      <div class="m_b_1">
        <label
          class="dashboards-maker--widget__form-title"
          for="widget-indicator-input-text"
        >
          {{ selectLabel }}
        </label>
        <input
          id="widget-indicator-input-text"
          type="text"
          :placeholder="placeholderLabel"
          class="dashboards-maker--widget__form-text"
        >
      </div>
      <div class="m_b_1">
        <label
          for=""
          class="dashboards-maker--widget__form-title"
        > {{ typeLabel }}
        </label>
        <template v-for="{ name } in subtypes">
          <label
            :key="name"
            :for="`widget-indicator-input-radio-${name}`"
            name="widget-indicator-input-radio"
            class="dashboards-maker--widget__form-label"
          >
            <input
              id="widget-indicator-input-radio"
              type="radio"
              name="widget-indicator-input-radio"
              class="dashboards-maker--widget__form-radio"
            >
            {{ name }}
          </label>
        </template>
      </div>
      <div>
        <Button>
          {{ saveLabel }}
        </Button>
      </div>
    </form>
  </div>
</template>

<script>
import { Widgets } from "../lib/widgets"
import Button from "./Button"

export default {
  name: "WidgetIndicator",
  components: {
    Button
  },
  props: {
    template: {
      type: String,
      default: null
    },
    edit: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      subtypes: Widgets.INDICATOR.subtypes,
      indicator: null,
      selectLabel: "Selecciona el indicador",
      typeLabel: "Tipo",
      saveLabel: "Guardar",
      placeholderLabel: "Escribe el título del indicador o proyecto",
    }
  },
  created() {
    this.indicator = this.subtypes[this.template].template
  }
}
</script>