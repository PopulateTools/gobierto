<template>
  <GridItem
    :x="x"
    :y="y"
    :w="w"
    :h="h"
    :i="i"
    :static="edit"
  >
    <WidgetEditable
      :disabled="!editionMode"
      @edit="handleWidgetEdit"
      @delete="handleWidgetDelete"
    >
      <component
        :is="template"
        v-bind="{ ...attributes, edit }"
      />
    </WidgetEditable>
  </GridItem>
</template>

<script>
import { GridItem } from "vue-grid-layout";
import WidgetEditable from "./WidgetEditable";

export default {
  name: "Widget",
  components: {
    GridItem,
    WidgetEditable
  },
  props: {
    x: {
      type: Number,
      required: true
    },
    y: {
      type: Number,
      required: true
    },
    w: {
      type: Number,
      required: true
    },
    h: {
      type: Number,
      required: true
    },
    i: {
      type: [String, Number],
      required: true
    },
    attributes: {
      type: Object,
      default: () => {}
    },
    template: {
      type: Function,
      default: () => {}
    },
    editionMode: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      edit: false
    }
  },
  methods: {
    handleWidgetEdit() {
      this.edit = !this.edit
    },
    handleWidgetDelete() {
      this.$emit('delete', this.i)
    }
  }
};
</script>
