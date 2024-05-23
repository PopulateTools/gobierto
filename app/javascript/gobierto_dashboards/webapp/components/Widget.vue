<template>
  <GridItem
    ref="item"
    :x="x"
    :y="y"
    :w="w"
    :h="h"
    :i="i"
    :static="edit"
  >
    <WidgetEditable
      v-clickoutside="handleClickOutside"
      :disabled="!editionMode"
      @edit="handleWidgetEdit"
      @delete="handleWidgetDelete"
    >
      <component
        :is="template"
        v-bind="{ ...$attrs, edit }"
        @change="handleWidgetChange"
      />
    </WidgetEditable>
  </GridItem>
</template>

<script>
import { GridItem } from 'vue-grid-layout';
import WidgetEditable from './WidgetEditable.vue';
import { clickoutside } from '../../../lib/vue/directives'

export default {
  name: "Widget",
  components: {
    GridItem,
    WidgetEditable
  },
  directives: { clickoutside },
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
    template: {
      type: Object,
      default: () => {}
    },
    editionMode: {
      type: Boolean,
      default: false
    },
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
    },
    handleWidgetChange(value) {
      this.edit = false
      this.$emit('change', this.i, value)
    },
    handleClickOutside() {
      if (this.edit) {
        this.edit = false
      }
    },
  }
};
</script>
