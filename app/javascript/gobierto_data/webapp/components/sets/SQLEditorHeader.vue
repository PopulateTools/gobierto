<template>
  <div>
    <div class="gobierto-data-sql-editor-toolbar">
      <Button
        v-if="showBtnRemove"
        class="btn-sql-editor"
        :text="undefined"
        icon="times"
        color="var(--color-base)"
        background="#fff"
      />
      <Button
        class="btn-sql-editor"
        :class="removeLabelBtn ? 'remove-label' : ''"
        :text="labelRecents"
        icon="history"
        color="var(--color-base)"
        background="#fff"
        :disabled="disabledRecents"
      />
      <Button
        class="btn-sql-editor"
        :class="removeLabelBtn ? 'remove-label' : ''"
        :text="labelQueries"
        icon="list"
        color="var(--color-base)"
        :disabled="disabledQueries"
        background="#fff"
      />
      <div
        v-if="saveQueryState"
        class="gobierto-data-sql-editor-container-save"
      >
        <input
          ref="inputText"
          type="text"
          :placeholder="labelQueryName"
          :class="disableInputName ? 'disable-input-text' : ' '"
          class="gobierto-data-sql-editor-container-save-text"
          @keyup="nameQuery = $event.target.value"
        >
        <input
          v-if="showLabelPrivate"
          :id="labelPrivate"
          type="checkbox"
          class="gobierto-data-sql-editor-container-save-checkbox"
          :checked="privateQuery"
          @input="privateQuery = $event.target.checked"
        >
        <label
          v-if="showLabelPrivate"
          class="gobierto-data-sql-editor-container-save-label"
          :for="labelPrivate"
        >
          {{ labelPrivate }}
        </label>
        <i
          style="color: #A0C51D;"
          class="fas"
          :class="privateQuery ? 'fa-lock' : 'fa-lock-open'"
        />
        <span
          v-if="showLabelModified"
          class="gobierto-data-sql-editor-modified-label"
        >
          {{ labelModifiedQuery }}
        </span>
      </div>
      <Button
        v-if="showBtnSave"
        class="btn-sql-editor"
        :style="saveQueryState ? 'color: #fff; background-color: var(--color-base)' : 'color: var(--color-base); background-color: rgb(255, 255, 255);'"
        :text="labelSave"
        icon="save"
        color="var(--color-base)"
        background="#fff"
        :disabled="disabledSave"
        @click.native="saveQueryName()"
      />
      <Button
        v-if="showBtnCancel"
        class="btn-sql-editor"
        :text="labelCancel"
        icon="undefined"
        color="var(--color-base)"
        background="#fff"
        @click.native="cancelQuery()"
      />
      <Button
        v-if="showBtnEdit"
        class="btn-sql-editor"
        :text="labelEdit"
        icon="edit"
        color="var(--color-base)"
        background="#fff"
        @click.native="editQuery()"
      />
      <Button
        v-if="showBtnRun"
        class="btn-sql-editor btn-sql-editor-run"
        :text="labelRunQuery"
        icon="play"
        color="var(--color-base)"
        background="#fff"
        :disabled="disabledRunQuery"
        @click.native="runQuery()"
      />
    </div>
  </div>
</template>
<script>
import Button from "./../commons/Button.vue";

export default {
  name: 'SQLEditorHeader',
  components: {
    Button
  },
  data() {
    return {
      disabledRecents: true,
      disabledQueries: false,
      disabledSave: true,
      disabledRunQuery: true,
      disableInputName: false,
      saveQueryState: false,
      marked: false,
      privateQuery: false,
      showBtnCancel: false,
      showBtnEdit: false,
      showBtnRun: true,
      showBtnSave: true,
      showBtnRemove: true,
      showLabelPrivate: true,
      removeLabelBtn: false,
      showLabelModified: false,
      labelSave: '',
      labelRecents: '',
      labelQueries: '',
      labelRunQuery: '',
      labelCancel: '',
      labelPrivate: '',
      labelQueryName: '',
      labelEdit: '',
      labelModifiedQuery: '',
      nameQuery: '',
      codeQuery: ''
    }
  },
  created() {
    this.labelSave = I18n.t("gobierto_data.projects.save")
    this.labelRecents = I18n.t("gobierto_data.projects.recents")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelRunQuery = I18n.t("gobierto_data.projects.runQuery")
    this.labelCancel = I18n.t("gobierto_data.projects.cancel")
    this.labelPrivate = I18n.t("gobierto_data.projects.private")
    this.labelQueryName = I18n.t("gobierto_data.projects.queryName")
    this.labelEdit = I18n.t("gobierto_data.projects.edit")
    this.labelModifiedQuery = I18n.t("gobierto_data.projects.modifiedQuery")
    this.labelGuide = I18n.t("gobierto_data.projects.guide")

    this.$root.$on("activeSave", this.activeSave);
    this.$root.$on("updateCode", this.updateQuery);
    this.$root.$on("updateActiveSave", this.updateActiveSave);
  },
  methods: {
    activeSave(value) {
      this.disabledRecents = value
      this.disabledSave = value
      this.disabledRunQuery = value
    },
    updateQuery(value) {
      this.codeQuery = value
    },
    updateActiveSave(activeLabel, disableLabel) {
      this.showLabelModified = activeLabel
      this.showBtnSave = activeLabel
      this.showBtnEdit = disableLabel
      this.disableInputName = disableLabel
    },
    saveQueryName() {
      if (this.saveQueryState === true && this.nameQuery.length > 0) {
        this.showBtnCancel = false
        this.showBtnEdit = true
        this.showBtnSave = false
        this.showBtnRemove = false
        this.showLabelPrivate = false
        this.removeLabelBtn = true
        this.showLabelModified = false
        this.disableInputName = true
      } else {
        this.saveQueryState = true
        this.showBtnCancel = true
        this.setFocus()
        this.$root.$emit("saveQueryState", true);
      }
    },
    setFocus() {
      this.$nextTick(() => {
        this.$refs.inputText.focus()
      })
    },
    editQuery() {
      this.setFocus()
      this.showBtnCancel = true
      this.showBtnEdit = false
      this.showBtnSave = true
      this.showBtnRemove = true
      this.showLabelPrivate = true
      this.removeLabelBtn = false
      this.disableInputName = false
    },
    cancelQuery() {
      if (this.nameQuery.length > 0) {
        this.showBtnCancel = false
        this.showBtnEdit = true
        this.showBtnSave = false
        this.showBtnRemove = false
        this.showLabelPrivate = false
        this.removeLabelBtn = true
        this.showLabelModified = false
        this.disableInputName = true
      } else {
        this.showBtnCancel = false
        this.showBtnEdit = false
        this.showBtnSave = true
        this.showBtnRemove = true
        this.showLabelPrivate = true
        this.removeLabelBtn = false
        this.saveQueryState = false
      }
    }
  }
}
</script>
