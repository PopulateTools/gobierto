<template>
  <Header>
    <div class="dashboards-maker--header m_b_1">
      <Editable
        tag="h1"
        @input="handleInputTitle"
      >
        {{ currentTitle }}
      </Editable>
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
      <Button @click.native="handleSaveButton">
        {{ saveLabel }}
      </Button>
    </div>
  </Header>
</template>

<script>
import Header from "../layouts/Header.vue";
import Editable from "../components/Editable.vue";
import Button from "../components/Button.vue";

export default {
  name: "HeaderContent",
  components: {
    Header,
    Editable,
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
      status: false,
      deleteLabel: "Eliminar",
      saveLabel: "Guardar",
      publicLabel: "Público",
      seeItemLabel: "Ver ítem"
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
    },
    handleInputStatus({ target }) {
      this.status = target.checked;
    },
    handleDeleteButton() {
      console.log("not implemented button");
    },
    handleSeeItemButton() {
      console.log("not implemented button");
    },
    handleSaveButton() {
      console.log("not implemented button");
    },
  }
};
</script>
