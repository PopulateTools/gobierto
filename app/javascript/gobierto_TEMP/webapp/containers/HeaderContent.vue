<template>
  <Header>
    <div class="dashboards-maker--header m_b_1">
      <TextEditable
        tag="h1"
        @input="handleInputTitle"
      >
        {{ currentTitle }}
      </TextEditable>
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
import TextEditable from "../components/TextEditable.vue";
import Button from "../components/Button.vue";

export default {
  name: "HeaderContent",
  components: {
    Header,
    TextEditable,
    Button
  },
  props: {
    title: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      isDirty: false,
      status: false,
      deleteLabel: "Eliminar",
      saveLabel: "Guardar",
      publicLabel: "Público",
      seeItemLabel: "Ver ítem",
      changesLabel: "Dashboard modificado"
    };
  },
  computed: {
    currentTitle() {
      return this.title || "Título del dashboard"
    }
  },
  methods: {
    handleInputTitle(title) {
      this.currentTitle = title;
      this.isDirty = true
    },
    handleInputStatus({ target }) {
      this.status = target.checked;
      this.isDirty = true
    },
    handleDeleteButton() {
      console.warn("not implemented button");
    },
    handleSeeItemButton() {
      console.warn("not implemented button");
    },
    handleSaveButton() {
      console.warn("not implemented button");
    },
  }
};
</script>
