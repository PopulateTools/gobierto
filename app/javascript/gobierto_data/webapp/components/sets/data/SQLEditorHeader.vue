<template>
  <div>
    <div class="gobierto-data-sql-editor-toolbar">
      <div class="gobierto-data-sql-editor-container-recent-queries">
        <Button
          v-clickoutside="closeRecentModal"
          :text="labelRecents"
          :class="removeLabelBtn ? 'remove-label' : ''"
          :title="labelButtonRecentQueries"
          class="btn-sql-editor"
          icon="history"
          color="var(--color-base)"
          background="#fff"
          @click.native="isRecentModalActive = !isRecentModalActive"
        />

        <transition
          name="fade"
          mode="out-in"
        >
          <RecentQueries
            v-if="isRecentModalActive"
            :table-name="tableName"
            :class="[isRecentModalActive ? 'active' : '']"
          />
        </transition>
      </div>

      <div class="gobierto-data-sql-editor-your-queries">
        <Button
          v-clickoutside="closeQueriesModal"
          :text="labelQueries"
          :class="removeLabelBtn ? 'remove-label' : ''"
          :title="labelButtonQueries"
          class="btn-sql-editor"
          icon="list"
          color="var(--color-base)"
          background="#fff"
          @click.native="isQueriesModalActive = !isQueriesModalActive"
        />

        <transition
          name="fade"
          mode="out-in"
        >
          <Queries
            v-if="isQueriesModalActive"
            :private-queries="privateQueries"
            :public-queries="publicQueries"
            class="gobierto-data-sets-nav--tab-container gobierto-data-sql-editor-your-queries-container arrow-top"
          />
        </transition>
      </div>

      <input
        v-if="isSavingDialogActive || showInputName"
        ref="inputText"
        v-model="labelQueryName"
        :class="disableInputName ? 'disable-input-text' : ' '"
        type="text"
        class="gobierto-data-sql-editor-container-save-text"
        @keyup="onSave($event.target.value)"
        @focus="onFocusEditor"
      >

      <label
        v-if="isSavingDialogActive || showLabelPrivate"
        :for="labelPrivate"
        class="gobierto-data-sql-editor-container-save-label"
      >
        <input
          :id="labelPrivate"
          :checked="isPrivateQuery"
          type="checkbox"
          class="gobierto-data-sql-editor-container-save-checkbox"
          @input="clickPrivateQueryHandler($event)"
        >
        {{ labelPrivate }}
      </label>

      <PrivateIcon
        v-if="isSavingDialogActive || showPrivateIcon"
        :is-closed="isPrivateQuery"
      />

      <span
        v-if="showLabelModified"
        class="gobierto-data-sql-editor-modified-label"
      >
        {{ labelModifiedQuery }}
      </span>

      <Button
        v-if="showBtnSave"
        :text="labelSave"
        :style="
          isSavingDialogActive
            ? 'color: #fff; background-color: var(--color-base)'
            : 'color: var(--color-base); background-color: rgb(255, 255, 255);'
        "
        class="btn-sql-editor"
        icon="save"
        color="var(--color-base)"
        background="#fff"
        @click.native="clickSaveQueryHandler()"
      />

      <Button
        v-if="showBtnCancel"
        :text="labelCancel"
        class="btn-sql-editor btn-sql-editor-cancel"
        icon="undefined"
        color="var(--color-base)"
        background="#fff"
        @click.native="clickCancelQueryHandler()"
      />

      <Button
        v-if="showBtnEdit"
        :text="labelEdit"
        class="btn-sql-editor"
        icon="edit"
        color="var(--color-base)"
        background="#fff"
        @click.native="clickEditQueryHandler()"
      />

      <Button
        :text="labelRunQuery"
        :title="labelButtonRunQuery"
        class="btn-sql-editor btn-sql-editor-run"
        icon="play"
        color="var(--color-base)"
        background="#fff"
        @click.native="clickRunQueryHandler()"
      >
        <PulseSpinner v-if="isQueryRunning" />
      </Button>
    </div>
  </div>
</template>
<script>
import { getUserId } from "./../../../../lib/helpers";
import { CommonsMixin, closableMixin } from "./../../../../lib/commons.js";

import Button from "./../../commons/Button.vue";
import Queries from "./../../commons/Queries.vue";
import PulseSpinner from "./../../commons/PulseSpinner.vue";
import PrivateIcon from "./../../commons/PrivateIcon.vue";
import RecentQueries from "./RecentQueries.vue";

export default {
  name: "SQLEditorHeader",
  components: {
    Button,
    RecentQueries,
    Queries,
    PulseSpinner,
    PrivateIcon,
  },
  mixins: [CommonsMixin, closableMixin],
  props: {
    privateQueries: {
      type: Array,
      default: () => [],
    },
    publicQueries: {
      type: Array,
      default: () => [],
    },
    isQueryRunning: {
      type: Boolean,
      default: false
    },
    tableName: {
      type: String,
      default: "",
    },
    queryName: {
      type: String,
      default: null,
    },
  },
  data() {
    return {
      labelSave: I18n.t("gobierto_data.projects.save") || "",
      labelRecents: I18n.t("gobierto_data.projects.recents") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelRunQuery: I18n.t("gobierto_data.projects.runQuery") || "",
      labelCancel: I18n.t("gobierto_data.projects.cancel") || "",
      labelPrivate: I18n.t("gobierto_data.projects.private") || "",
      labelQueryName:
        this.queryName || I18n.t("gobierto_data.projects.queryName") || "",
      labelEdit: I18n.t("gobierto_data.projects.edit") || "",
      labelModifiedQuery: I18n.t("gobierto_data.projects.modifiedQuery") || "",
      labelButtonQueries: I18n.t("gobierto_data.projects.buttonQueries") || "",
      labelButtonRecentQueries:
        I18n.t("gobierto_data.projects.buttonRecentQueries") || "",
      labelButtonRunQuery:
        I18n.t("gobierto_data.projects.buttonRunQuery") || "",
      disableInputName: false,
      isPrivateQuery: false,
      showBtnSave: true,
      showBtnCancel: false,
      showBtnEdit: false,
      showInputName: false,
      showPrivateIcon: false,
      showLabelModified: false,
      showLabelPrivate: false,
      removeLabelBtn: false,
      isSavingDialogActive: false,
      isQueriesModalActive: false,
      isRecentModalActive: false,
    };
  },
  created() {
    this.$root.$on("updateActiveSave", this.updateActiveSave);

    this.$root.$on("blurEditor", this.onBlurEditor);
    this.$root.$on("focusEditor", this.onFocusEditor);

    // Allow the shortcuts at startup
    this.onBlurEditor();
  },
  beforeDestroy() {
    this.$root.$off("updateActiveSave", this.updateActiveSave);
    this.$root.$off("blurEditor", this.onBlurEditor);
    this.$root.$off("focusEditor", this.onFocusEditor);
  },
  methods: {
    modalShortcutsListener(e) {
      if (e.keyCode == 67) {
        // key "c"
        this.openQueriesModal();
      } else if (e.keyCode == 82) {
        // key "r"
        this.openRecentModal();
      }
    },
    editorShortcutsListener(e) {
      if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
        this.clickRunQueryHandler();
      }
    },
    onBlurEditor() {
      // Enable keyboard listeners (c|r)
      window.addEventListener("keydown", this.modalShortcutsListener, true);
      // Disable run query on ctrl+enter
      window.removeEventListener("keydown", this.editorShortcutsListener, true);
    },
    onFocusEditor() {
      // Disable keyboard listeners (c|r) for typing the query
      window.removeEventListener("keydown", this.modalShortcutsListener, true);
      // Enable run query on ctrl+enter
      window.addEventListener("keydown", this.editorShortcutsListener, true);
    },
    onSave(queryName) {
      this.labelQueryName = queryName;
    },
    showStoreQueries(queries) {
      this.$root.$emit("showRecentQueries", queries);
    },
    updateActiveSave(activeLabel, disableLabel) {
      console.log("updateActiveSave", activeLabel, disableLabel);

      this.showLabelModified = activeLabel;
      this.showBtnSave = activeLabel;
      this.showBtnEdit = disableLabel;
      this.disableInputName = disableLabel;
    },
    setFocus() {
      this.$nextTick(() => this.$refs.inputText.focus());
    },
    clickRunQueryHandler() {
      this.$root.$emit("runCurrentQuery");
    },
    clickSaveQueryHandler() {
      // if there's no user, you cannot save queries
      if (getUserId() === "")
        location.href = "/user/sessions/new?open_modal=true";

      if (this.isSavingDialogActive && this.labelQueryName.length > 0) {
        this.$root.$emit("storeCurrentQuery", {
          name: this.labelQueryName,
          privacy: this.isPrivateQuery,
        });
        this.closeSavingDialog();
      } else {
        this.openSavingDialog();
      }
    },
    clickPrivateQueryHandler(e) {
      const { checked } = e.target;
      this.isPrivateQuery = checked;
    },
    clickEditQueryHandler() {
      this.openSavingDialog();
    },
    clickCancelQueryHandler() {
      this.closeSavingDialog();
    },
    openSavingDialog() {
      this.isSavingDialogActive = true;

      this.setFocus();

      this.showBtnSave = true;
      this.showBtnCancel = true;
      this.showPrivateIcon = true;
      this.showLabelPrivate = true;
      this.showInputName = true;

      // enable input
      this.showBtnEdit = false;
      this.disableInputName = false;
    },
    closeSavingDialog() {
      this.isSavingDialogActive = false;
      this.showBtnCancel = false;
      this.showLabelPrivate = false;

      if (this.labelQueryName.length > 0) {
        this.showBtnSave = false;

        this.showBtnEdit = true;
        this.removeLabelBtn = true;
        this.showInputName = true;
        this.disableInputName = true;
        this.showPrivateIcon = true;
      } else {
        this.removeLabelBtn = false;
        this.showInputName = false;
        this.disableInputName = false;
        this.showPrivateIcon = false;
      }
    },
    openRecentModal() {
      this.isRecentModalActive = true;
    },
    closeRecentModal() {
      this.isRecentModalActive = false;
    },
    openQueriesModal() {
      this.isQueriesModalActive = true;
    },
    closeQueriesModal() {
      this.isQueriesModalActive = false;
    },
  },
};
</script>
