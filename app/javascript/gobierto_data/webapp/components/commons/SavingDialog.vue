<template>
  <div class="gobierto-data-sql-editor-container-save">
    <!--  only show if label name is set OR the prompt is visible  -->
    <template v-if="isSavingPromptVisible || labelElementName">
      <input
        ref="inputText"
        v-model="labelElementName"
        :placeholder="placeholder"
        :disabled="!isSavingPromptVisible"
        type="text"
        class="gobierto-data-sql-editor-container-save-text"
        @keydown.stop="onKeyUpTextHandler"
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
    <template v-if="isSavingPromptVisible || labelElementName">
      <PrivateIcon
        :is-closed="isPrivate"
        :style="{ paddingRight: '.5em', margin: 0 }"
      />
    </template>

    <!-- show edit button if there's no prompt but some name, otherwise, save button -->
    <template v-if="!isSavingPromptVisible && labelElementName">
      <Button
        :text="labelEdit"
        class="btn-sql-editor"
        icon="edit"
        color="var(--color-base)"
        background="#fff"
        @click.native="onClickEditHandler"
      />
    </template>
    <template v-else>
      <Button
        :text="labelSave"
        :style="
          isSavingPromptVisible
            ? 'color: #fff; background-color: var(--color-base)'
            : 'color: var(--color-base); background-color: rgb(255, 255, 255);'
        "
        :disabled="isSavingPromptVisible && !labelElementName"
        icon="save"
        color="var(--color-base)"
        background="#fff"
        class="gobierto-data-btn-download-data"
        @click.native="onClickSaveHandler"
      />
    </template>

    <!-- only show cancel button on prompt visible -->
    <template v-if="isSavingPromptVisible">
      <Button
        :text="labelCancel"
        class="btn-sql-editor btn-sql-editor-cancel"
        :icon="null"
        color="var(--color-base)"
        background="#fff"
        @click.native="onClickCancelHandler"
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
    placeholder: {
      type: String,
      default: ''
    },
    saveCallback: {
      type: Function,
      default: () => {}
    }
  },
  data() {
    return {
      isPrivate: false,
      isSavingPromptVisible: false,
      labelElementName: null,
      labelSave: I18n.t("gobierto_data.projects.save") || "",
      labelPrivate: I18n.t('gobierto_data.projects.private') || "",
      labelCancel: I18n.t('gobierto_data.projects.cancel') || "",
      labelEdit: I18n.t("gobierto_data.projects.edit") || ""
    }
  },
  methods: {
    onClickSaveHandler() {
      if (!this.isSavingPromptVisible) {
        this.isSavingPromptVisible = true
        this.$nextTick(() => this.$refs.inputText.focus());
      } else {
        // the output is the content of the input plus the private flag
        this.$emit('save', { name: this.labelElementName, privacy: this.isPrivate })

        this.isSavingPromptVisible = false
      }
    },
    onClickCancelHandler() {
      this.labelElementName = null
      this.isSavingPromptVisible = false
    },
    onClickEditHandler() {
      this.isSavingPromptVisible = true
    },
    onKeyUpTextHandler(event) {
      const { value } = event.target
      this.labelElementName = value
    },
    onInputCheckboxHandler(event) {
      const { checked } = event.target
      this.isPrivate = checked
    },
  }
}
</script>
