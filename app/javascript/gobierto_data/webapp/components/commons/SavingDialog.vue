<template>
  <div class="gobierto-data-sql-editor-container-save">
    <!--  only show if label name is set OR the prompt is visible  -->
    <template v-if="isQuerySavingPromptVisible || labelValue ||isVizSavingPromptVisible">
      <input
        ref="inputText"
        v-model="labelValue"
        :placeholder="placeholder"
        type="text"
        class="gobierto-data-sql-editor-container-save-text"
        @keydown.stop="onKeyDownTextHandler"
      >
    </template>

    <!-- only show checkbox on prompt visible -->
    <template v-if="isQuerySavingPromptVisible || isVizSavingPromptVisible">
      <label
        :for="labelPrivate"
        class="gobierto-data-sql-editor-container-save-label"
      >
        <input
          :id="labelPrivate"
          :checked="isPrivate"
          type="checkbox"
          @input="onInputCheckboxHandler"
        >
        {{ labelPrivate }}
      </label>
    </template>

    <!-- only show if label name is set OR the prompt is visible -->
    <template v-if="isQuerySavingPromptVisible || labelValue ||isVizSavingPromptVisible">
      <PrivateIcon
        :is-closed="isPrivate"
        :style="{ paddingRight: '.5em', margin: 0 }"
      />
    </template>

    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="isQueryModified || isVizModified">
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelModified }}
          </span>
        </div>
      </template>
    </transition>

    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="isQuerySaved || isVizSaved">
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelSave }}
          </span>
        </div>
      </template>
    </transition>


    <!-- show save button if there's no prompt but some name, otherwise, save button -->
    <Button
      :text="labelSave"
      :disabled="!isDisabled"
      icon="save"
      color="var(--color-base)"
      background="#fff"
      class="btn-sql-editor"
      @click.native="onClickSaveHandler"
    />

    <!-- only show revert button when loaded queries from others users -->
    <template v-if="showRevertQuery">
      <Button
        :text="labelRevert"
        :disabled="!enabledQuerySavedButton"
        icon="undo"
        class="btn-sql-editor btn-sql-editor-revert"
        color="var(--color-base)"
        background="#fff"
        @click.native="revertQueryHandler"
      />
    </template>
  </div>
</template>
<script>
import Button from "./Button.vue";
import PrivateIcon from "./PrivateIcon.vue";

export default {
  name: 'SavingDialog',
  components: {
    Button,
    PrivateIcon
  },
  props: {
    value: {
      type: String,
      default: ''
    },
    placeholder: {
      type: String,
      default: ''
    },
    labelSave: {
      type: String,
      default: ''
    },
    labelModified: {
      type: String,
      default: ''
    },
    isQueryModified: {
      type: Boolean,
      default: false
    },
    isVizModified: {
      type: Boolean,
      default: false
    },
    isQuerySavingPromptVisible: {
      type: Boolean,
      default: false
    },
    isVizSavingPromptVisible: {
      type: Boolean,
      default: false
    },
    enabledQuerySavedButton: {
      type: Boolean,
      default: false
    },
    enabledVizSavedButton: {
      type: Boolean,
      default: false
    },
    showRevertQuery: {
      type: Boolean,
      default: false
    },
    showPrivate: {
      type: Boolean,
      default: false
    },
    isQuerySaved: {
      type: Boolean,
      default: false
    },
    isVizSaved: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      isPrivate: false,
      labelValue: this.value,
      labelPrivate: I18n.t('gobierto_data.projects.private') || "",
      labelCancel: I18n.t('gobierto_data.projects.cancel') || "",
      labelEdit: I18n.t("gobierto_data.projects.edit") || "",
      labelRevert: I18n.t("gobierto_data.projects.revert") || "",
      labelSavedQuery: I18n.t("gobierto_data.projects.savedQuery") || ""
    }
  },
  computed: {
    isDisabled() {
      return this.enabledVizSavedButton || this.enabledQuerySavedButton ? true : false
    }
  },
  watch: {
    value(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.labelValue = newValue
      }
    },
    showPrivate(newValue) {
      this.isPrivate = (newValue);
    }
  },
  methods: {
    inputFocus() {
      this.$refs.inputText.focus()
    },
    onClickSaveHandler() {
      this.$emit('save', { name: this.labelValue, privacy: this.isPrivate })
    },
    onKeyDownTextHandler(event) {
      const { value } = event.target
      this.labelValue = value
      this.$emit('keyDownInput', { name: this.labelValue })
    },
    onInputCheckboxHandler(event) {
      const { checked } = event.target
      this.isPrivate = checked
    },
    revertQueryHandler() {
      this.$root.$emit('revertSavedQuery', true)
    }
  }
}
</script>
