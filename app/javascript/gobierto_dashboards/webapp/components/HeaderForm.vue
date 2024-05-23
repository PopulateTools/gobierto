<template>
  <Header :highlight="isDirty">
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
          v-if="showViewItem"
          icon="external-link-alt"
          template="link"
          @click.native="handleSeeItemButton"
        >
          {{ viewItemLabel }}
        </Button>
      </div>
    </div>
    <div class="dashboards-maker--header">
      <slot name="checkbox" />

      <div class="dashboards-maker--button">
        <i v-if="isDirty">{{ changesLabel }}</i>
        <Button
          v-if="isDirty"
          template="link"
          :class="{ 'is-shaking': shaking }"
          @click.native="handleCloseButton"
        >
          {{ closeNoSaveLabel }}
        </Button>
        <Button
          :disabled="!isDirty"
          :class="{ 'is-shaking': shaking }"
          @click.native="handleSaveButton"
        >
          {{ saveLabel }}
        </Button>
      </div>
    </div>
  </Header>
</template>

<script>
import Header from '../layouts/Header.vue';
import Button from './Button.vue';

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
    showViewItem: {
      type: Boolean,
      default: true
    },
    shaking: {
      type: Boolean,
      default: true
    },
  },
  data() {
    return {
      deleteLabel: I18n.t("gobierto_dashboards.delete") || "",
      saveLabel: I18n.t("gobierto_dashboards.save") || "",
      viewItemLabel: I18n.t("gobierto_dashboards.view_item") || "",
      changesLabel: I18n.t("gobierto_dashboards.changes") || "",
      closeNoSaveLabel: I18n.t("gobierto_dashboards.discard") || ""
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
    handleCloseButton() {
      this.$emit('close')
    },
  }
};
</script>
