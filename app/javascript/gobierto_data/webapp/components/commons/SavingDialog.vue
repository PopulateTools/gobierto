<template>
  <div class="gobierto-data-sql-editor-container-save">
    <!--  only show if label name is set OR the prompt is visible  -->
    <template v-if="isSavingPromptVisible || labelValue">
      <input
        ref="inputText"
        v-model="labelValue"
        :placeholder="placeholder"
        :disabled="!isSavingPromptVisible"
        type="text"
        class="gobierto-data-sql-editor-container-save-text"
        @keydDownn.stop="onKeyUpTextHandler"
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

    <!-- show edit button if there's no prompt but some name, otherwise, save button -->
    <template v-if="!isSavingPromptVisible && labelValue">
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
        :disabled="isSavingPromptVisible && !labelValue"
        icon="save"
        color="var(--color-base)"
        background="#fff"
        class="btn-sql-editor"
        @click.native="onClickSaveHandler"
      />
    </template>

    <!-- only show cancel button on prompt visible -->
    <template v-if="isSavingPromptVisible">
      <Button
        :text="labelCancel"
        :icon="null"
        class="btn-sql-editor btn-sql-editor-cancel"
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
    value: {
      type: String,
      default: ''
    },
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
      labelValue: this.value,
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
        this.$emit('save', { name: this.labelValue, privacy: this.isPrivate })

        this.isSavingPromptVisible = false
      }
    },
    onClickCancelHandler() {
      this.labelValue = null
      this.isSavingPromptVisible = false
    },
    onClickEditHandler() {
      this.isSavingPromptVisible = true
      this.$nextTick(() => this.$refs.inputText.focus());
    },
    onKeyDownTextHandler(event) {
      const { value } = event.target
      this.labelValue = value
    },
    onInputCheckboxHandler(event) {
      const { checked } = event.target
      this.isPrivate = checked
    },
  }
}
</script>
