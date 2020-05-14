<template>
  <div class="gobierto-data-sql-editor-container-save">
    <!--  only show if label name is set OR the prompt is visible  -->
    <template v-if="isSavingPromptVisible || labelValue">
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
    <template v-if="isSavingPromptVisible">
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
    <template v-if="isSavingPromptVisible || labelValue">
      <PrivateIcon
        :is-closed="isPrivate"
        :style="{ paddingRight: '.5em', margin: 0 }"
      />
    </template>

    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="isQueryModified">
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelModifiedQuery }}
          </span>
        </div>
      </template>
    </transition>

    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="isQuerySaved">
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelSavedQuery }}
          </span>
        </div>
      </template>
    </transition>


    <!-- show edit button if there's no prompt but some name, otherwise, save button -->
    <Button
      :text="labelSave"
      :style="
        isSavingPromptVisible
          ? 'color: #fff; background-color: var(--color-base)'
          : 'color: var(--color-base); background-color: rgb(255, 255, 255);'
      "
      :disabled="!enabledSavedButton"
      icon="save"
      color="var(--color-base)"
      background="#fff"
      class="btn-sql-editor"
      @click.native="onClickSaveHandler"
    />

    <!-- only show cancel button on prompt visible -->
    <template v-if="showRevertQuery">
      <Button
        :text="labelRevert"
        :disabled="!enabledSavedButton"
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
    isQueryModified: {
      type: Boolean,
      default: false
    },
    isSavingPromptVisible: {
      type: Boolean,
      default: false
    },
    enabledSavedButton: {
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
      labelModifiedQuery: I18n.t("gobierto_data.projects.modifiedQuery") || "",
      labelSavedQuery: I18n.t("gobierto_data.projects.savedQuery") || ""
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
      this.$root.$emit('enableSavedButton')
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
