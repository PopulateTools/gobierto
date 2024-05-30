<template>
  <div class="gobierto-data-sql-editor-container-save">
    <!--  only show if label name is set OR the prompt is visible  -->
    <template v-if="handlerInputQuery">
      <input
        ref="inputText"
        v-model="labelValue"
        :placeholder="placeholder"
        type="text"
        class="gobierto-data-sql-editor-container-save-text"
        :class="{
          'disable-input-text': disabledButton,
          'disable-cursor-pointer': disabledInputName
        }"
        @keydown.stop="onKeyDownTextHandler"
        @click="enabledInputHandler"
      >
    </template>

    <!-- only show checkbox on prompt visible -->
    <template v-if="showPrivateIcon && isUserLogged">
      <PrivateIcon
        :is-closed="isPrivate"
        :style="{ paddingRight: '.5em', margin: 0 }"
      />
      <div
        v-if="showLabelPrivate"
        class="gobierto-data-sql-editor-container-save-label"
      >
        <input
          :id="labelPrivate"
          :checked="isPrivate"
          type="checkbox"
          class="gobierto-data-sql-editor-container-save-label-input"
          @input="onInputCheckboxHandler"
        >
        <label
          :for="labelPrivate"
          class="gobierto-data-sql-editor-container-save-label-text"
        >
          {{ labelPrivate }}
        </label>
      </div>
    </template>

    <!-- show save button if there's no prompt but some name, otherwise, save button -->
    <Button
      v-if="showSaveButton"
      :text="labelSave"
      icon="save"
      background="#fff"
      class="btn-sql-editor"
      @click.native="onClickSaveHandler"
    />

    <Button
      v-if="showForkButton"
      :text="labelFork"
      :title="labelButtonFork"
      icon="code-branch"
      background="#fff"
      class="btn-sql-editor"
      @click.native="onClickForkHandler"
    />

    <!-- only show revert button when loaded queries from others users -->
    <template v-if="showRevertButton">
      <Button
        :text="labelRevert"
        icon="undo"
        class="btn-sql-editor btn-sql-editor-revert"
        background="#fff"
        @click.native="revertQueryHandler"
      />
    </template>

    <template v-if="showEditButton">
      <Button
        :text="labelEdit"
        class="btn-sql-editor btn-sql-revert-query"
        icon="chart-area"
        background="#fff"
        @click.native="showChart"
      />
    </template>
    <template v-if="isVizItemModified">
      <Button
        :text="labelCancel"
        class="btn-sql-editor btn-sql-revert-query"
        icon="undo"
        background="#fff"
        @click.native="revertViz"
      />
    </template>

    <!-- only show if label name is set OR the prompt is visible -->
    <template v-if="isQueryOrVizModified">
      <transition
        name="fade"
        mode="out-in"
      >
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelModified }}
          </span>
        </div>
      </transition>
    </template>
    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="isQueryOrVizSaved">
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelSaved }}
          </span>
        </div>
      </template>
    </transition>
  </div>
</template>
<script>
import Button from './Button.vue';
import PrivateIcon from './PrivateIcon.vue';

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
    labelSaved: {
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
    isForkPromptVisible: {
      type: Boolean,
      default: true
    },
    isUserLogged: {
      type: Boolean,
      default: true
    },
    enabledVizSavedButton: {
      type: Boolean,
      default: false
    },
    enabledForkButton: {
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
    },
    enabledForkVizButton: {
      type: Boolean,
      default: false
    },
    showPrivatePublicIcon: {
      type: Boolean,
      default: false
    },
    showPrivatePublicIconViz: {
      type: Boolean,
      default: false
    },
    showPrivateViz: {
      type: Boolean,
      default: false
    },
    showLabelEdit: {
      type: Boolean,
      default: false
    },
    isVizItemModified: {
      type: Boolean,
      default: false
    },
    resetPrivate: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      isPrivate: false,
      disabledButton: true,
      labelValue: this.value,
      labelPrivate: I18n.t('gobierto_data.projects.private') || "",
      labelCancel: I18n.t('gobierto_data.projects.cancel') || "",
      labelEdit: I18n.t("gobierto_data.projects.edit") || "",
      labelRevert: I18n.t("gobierto_data.projects.revert") || "",
      labelSavedQuery: I18n.t("gobierto_data.projects.savedQuery") || "",
      labelSave: I18n.t("gobierto_data.projects.save") || "",
      labelButtonFork: I18n.t("gobierto_data.projects.buttonFork") || "",
      labelFork: I18n.t("gobierto_data.projects.createCopy") || "",
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
    }
  },
  computed: {
    showForkButton() {
      return this.enabledForkVizButton || this.enabledForkButton
    },
    handlerInputQuery() {
       return (this.isUserLogged && this.isQuerySavingPromptVisible) || this.labelValue || this.isVizSavingPromptVisible
    },
    showPrivateIcon() {
      return this.showPrivatePublicIcon || (this.showPrivatePublicIconViz && !this.showForkButton)
    },
    isQueryOrVizModified() {
      return this.isQueryModified || this.isVizModified
    },
    isQueryOrVizSaved() {
      return this.isQuerySaved || this.isVizSaved
    },
    showEditButton() {
      return this.showLabelEdit && (!this.isVizItemModified && !this.showForkButton)
    },
    showRevertButton() {
      return this.showRevertQuery && this.isQueryOrVizModified
    },
    showSaveButton() {
      return !this.showForkButton && (this.isQueryOrVizModified || this.isVizItemModified)
    },
    showLabelPrivate() {
      return this.isQueryModified || this.isVizModified || this.isVizItemModified
    },
    disabledInputName() {
      return this.enabledForkButton || !this.isUserLogged || this.enabledForkVizButton
    }
  },
  watch: {
    value(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.labelValue = newValue
        this.countInputCharacters(newValue)
        this.disabledButton = true
      }
    },
    showPrivate(newValue) {
      this.isPrivate = (newValue);
    },
    resetPrivate(newValue) {
      if (newValue) {
        this.isPrivate = false
      }
    }
  },
  created() {
    this.isPrivate = this.showPrivateViz
  },
  mounted() {
    this.countInputCharacters(this.value)
  },
  methods: {
    inputFocus(value) {
      if (value) {
        this.$refs.inputText.focus()
      } else {
        this.$refs.inputText.blur()
      }
    },
    inputSelect() {
      this.$refs.inputText.select()
    },
    onClickSaveHandler() {
      if (!this.isUserLogged) {
        location.href = '/user/sessions/new?open_modal=true';
        return false;
      }

      if (!this.labelValue) {
        this.$refs.inputText.focus()
      } else {
        this.$emit('save', { name: this.labelValue, privacy: this.isPrivate })
      }
    },
    onKeyDownTextHandler(event) {
      const { value } = event.target
      this.labelValue = value
      this.$emit('keyDownInput', { name: this.labelValue })
      this.countInputCharacters(value)
    },
    onInputCheckboxHandler(event) {
      const { checked } = event.target
      this.isPrivate = checked
      this.$emit('isPrivateChecked')
    },
    revertQueryHandler() {
      this.labelValue = this.value
      this.$root.$emit('revertSavedQuery')
      this.disabledButton = true
    },
    onClickForkHandler() {
      this.$emit('handlerFork')
      this.disabledButton = false
    },
    countInputCharacters(label) {

      if (!label) return false;

      const inputValueSplit = [...label]
      const inputValueLength = inputValueSplit.length

      let newWidth = inputValueLength * 7.5
      let maxWidth = 289.5
      let minWidth = 200
      newWidth = newWidth > 290 ? maxWidth : newWidth

      //Check if the user is typing in the input of the queries or visualizations
      const { placeholder = [] } = this.$refs.inputText || {};

      //In the Visualizations view, we've more space, so we take advantage of it by increasing the input name width.
      if (this.$route.name === 'Visualization') {
        maxWidth = maxWidth * 1.4
        minWidth = minWidth * 1.4
      } else if (placeholder) {
        maxWidth = maxWidth * 1.2
        minWidth = minWidth * 1.2
      }

      if (inputValueLength > 25 && inputValueLength < 50) {
        this.$nextTick(() => this.$refs.inputText.style.width = `${newWidth}px`);
      } else if (inputValueLength >= 50) {
        this.$nextTick(() => this.$refs.inputText.style.width = `${maxWidth}px`);
      } else {
        this.$nextTick(() => this.$refs.inputText.style.width = `${minWidth}px`);
      }
    },
    enabledInputHandler() {
      this.$emit('enabledInput')
    },
    showChart() {
      this.$emit('showToggleConfig')
    },
    revertViz() {
      this.$emit('handlerRevertViz')
      this.disabledButton = true
    }
  }
}
</script>
