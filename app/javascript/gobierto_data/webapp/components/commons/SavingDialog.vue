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
            'disable-cursor-pointer': enabledForkButton || !isUserLogged || enabledForkVizButton
          }"
          @keydown.stop="onKeyDownTextHandler"
          @click="enabledInputHandler"
        >
    </template>

    <!-- only show checkbox on prompt visible -->
    <template v-if="enableForkPrompt">
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
    <template v-if="handlerInputQuery">
      <PrivateIcon
        :is-closed="isPrivate"
        :style="{ paddingRight: '.5em', margin: 0 }"
      />
      <template v-if="isQueryModified || isVizModified">
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
    </template>


    <transition
      name="fade"
      mode="out-in"
    >
      <template v-if="isQuerySaved || isVizSaved">
        <div class="gobierto-data-sql-editor-modified-label-container">
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelSaved }}
          </span>
        </div>
      </template>
    </transition>


    <!-- show save button if there's no prompt but some name, otherwise, save button -->
    <Button
      v-if="!showForkButton"
      :text="labelSave"
      :disabled="!isDisabled"
      icon="save"
      background="#fff"
      class="btn-sql-editor"
      @click.native="onClickSaveHandler"
    />

    <Button
      v-if="showForkButton"
      :text="labelFork"
      :title="labelButtonFork"
      :disabled="!isDisabledFork"
      icon="code-branch"
      background="#fff"
      class="btn-sql-editor"
      @click.native="onClickForkHandler"
    />

    <!-- only show revert button when loaded queries from others users -->
    <template v-if="showRevertQuery">
      <Button
        :text="labelRevert"
        :disabled="!enabledRevertButton"
        icon="undo"
        class="btn-sql-editor btn-sql-editor-revert"
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
    enabledRevertButton: {
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
      labelButtonFork: I18n.t("gobierto_data.projects.buttonFork") || "",
      labelFork: I18n.t("gobierto_data.projects.fork") || ""
    }
  },
  computed: {
    isDisabled() {
      return this.enabledVizSavedButton || this.enabledQuerySavedButton
    },
    isDisabledFork() {
      return this.enabledQuerySavedButton || this.isVizModified
    },
    showForkButton() {
      return this.enabledForkVizButton || this.enabledForkButton
    },
    handlerInputQuery() {
       return (this.isUserLogged && this.isQuerySavingPromptVisible) || this.labelValue || this.isVizSavingPromptVisible
    },
    enableForkPrompt() {
      return (this.isForkPromptVisible && this.isUserLogged && this.isQuerySavingPromptVisible) || this.labelValue || this.isVizSavingPromptVisible
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
    isQuerySaved(newValue) {
      if (newValue) {
        this.disabledButton = true
      }
    },
    enabledForkButton(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.enabledForkButton = newValue
      }
    },
  },
  mounted() {
    if (this.$route.name === 'Query' && this.value !== null) {
      this.$nextTick(() => {
         this.countInputCharacters(this.value)
      });
    }
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

      this.$emit('save', { name: this.labelValue, privacy: this.isPrivate })
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
    },
    revertQueryHandler() {
      this.labelValue = this.value
      this.$root.$emit('revertSavedQuery', true)
    },
    onClickForkHandler() {
      this.$emit('handlerFork')
      this.disabledButton = false
    },
    countInputCharacters(label) {

      if (!label) return false;

      const inputValueSplit = [...label]
      const inputValueLength = inputValueSplit.length

      if (inputValueLength > 25 && inputValueLength < 50) {
        const newWidth = inputValueLength * 7.5
        this.$nextTick(() => this.$refs.inputText.style.width = `${newWidth}px`);
      } else if (inputValueLength >= 50) {
        this.$nextTick(() => this.$refs.inputText.style.width = '369.5px');
      } else {
        this.$nextTick(() => this.$refs.inputText.style.width = '200px');
      }
    },
    enabledInputHandler() {
      this.$emit('enabledInput')
    }
  }
}
</script>
