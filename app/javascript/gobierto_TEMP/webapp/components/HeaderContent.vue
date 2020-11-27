<template>
  <Header>
    <div class="dashboards-maker--header m_b_1">
      <slot />
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
      <label
        class="dashboards-maker--checkbox"
        for="dashboard-status"
      >
        <input
          id="dashboard-status"
          type="checkbox"
          @input="handleInputStatus"
        >
        {{ publicLabel }}
      </label>
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
  name: "HeaderContent",
  components: {
    Header,
    Button
  },
  props: {
    isDirty: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      status: false,
      deleteLabel: "Eliminar",
      saveLabel: "Guardar",
      publicLabel: "Público",
      seeItemLabel: "Ver ítem",
      changesLabel: "Dashboard modificado"
    };
  },
  methods: {
    handleInputStatus({ target }) {
      this.status = target.checked;
    },
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
