<template>
  <Header>
    <div class="dashboards-maker--header m_b_1">
      <slot name="title" />

      <div class="dashboards-maker--header dashboards-maker--header__buttons">
        <Button
          icon="trash"
          template="link"
          @click.native="handleDeleteButton"
        >
          {{ deleteLabel }}
        </Button>
        <Button
          icon="external-link-alt"
          template="link"
          @click.native="handleSeeItemButton"
        >
          {{ seeItemLabel }}
        </Button>
      </div>
    </div>
    <div class="dashboards-maker--header">
      <slot name="checkbox" />

      <div class="dashboards-maker--button">
        <i v-if="isDirty">{{ changesLabel }}</i>
        <Button
          :disabled="!isDirty"
          @click.native="handleSaveButton"
        >
          {{ saveLabel }}
        </Button>
      </div>
    </div>
  </Header>
</template>

<script>
import Header from "../layouts/Header.vue";
import Button from "./Button.vue";

export default {
  name: "HeaderForm",
  components: {
    Header,
    Button
  },
  props: {
    isDirty: {
      type: Boolean,
      default: false
    },
    config: {
      type: Object,
      default: () => {}
    },
  },
  data() {
    return {
      deleteLabel: "Eliminar",
      saveLabel: "Guardar",
      seeItemLabel: "Ver ítem",
      changesLabel: "Dashboard modificado"
    };
  },
  methods: {
    handleDeleteButton() {
      this.$emit('delete')
    },
    handleSeeItemButton() {
      this.$emit('view')
    },
    handleSaveButton() {
      this.$emit('save')
    },
  }
};
</script>
