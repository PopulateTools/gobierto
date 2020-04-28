<template>
  <div class="gobierto-data-sql-editor-toolbar">
    <div class="gobierto-data-sql-editor-container">
      <Button
        v-if="isQueryModified"
        :title="labelResetQuery"
        class="btn-sql-editor"
        icon="home"
        color="var(--color-base)"
        background="#fff"
        @click.native="resetQuery"
      />
      <Button
        v-clickoutside="closeRecentModal"
        :text="labelRecents"
        :class="{ 'remove-label' : removeLabelBtn }"
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
          :recent-queries="recentQueries"
          :class="{'active' : isRecentModalActive}"
          class="gobierto-data-sets-nav--tab-container gobierto-data-sql-editor-your-queries-container arrow-top"
        />
      </transition>
    </div>

    <div class="gobierto-data-sql-editor-container">
      <Button
        v-clickoutside="closeQueriesModal"
        :text="labelQueries"
        :class="{ 'remove-label' : removeLabelBtn }"
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
    <SavingDialog
      :placeholder="labelQueryName"
      :value="queryName"
      :label-save="labelSave"
      :is-query-modified="isQueryModified"
      :enabled-saved-button="enabledSavedButton"
      :show-revert-query="showRevertQuery"
      :show-private="showPrivate"
      @save="onSaveEventHandler"
      @showLabelIcons="showHideLabelIcons(false)"
      @revertQuery="revertQuery"
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
</template>
<script>
import { CommonsMixin, closableMixin } from "./../../../../lib/commons.js";

import Button from "./../../commons/Button.vue";
import Queries from "./../../commons/Queries.vue";
import PulseSpinner from "./../../commons/PulseSpinner.vue";
import RecentQueries from "./../../commons/RecentQueries.vue";
import SavingDialog from "./../../commons/SavingDialog.vue";

export default {
  name: "SQLEditorHeader",
  components: {
    Button,
    RecentQueries,
    Queries,
    PulseSpinner,
    SavingDialog
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
    recentQueries: {
      type: Array,
      default: () => []
    },
    isQueryRunning: {
      type: Boolean,
      default: false
    },
    isQueryModified: {
      type: Boolean,
      default: false
    },
    queryName: {
      type: String,
      default: '',
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
    }
  },
  data() {
    return {
      labelRecents: I18n.t("gobierto_data.projects.recents") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelRunQuery: I18n.t("gobierto_data.projects.runQuery") || "",
      labelResetQuery: I18n.t("gobierto_data.projects.resetQuery") || "",
      labelSave: I18n.t("gobierto_data.projects.save") || "",
      labelQueryName: I18n.t("gobierto_data.projects.queryName") || "",
      labelButtonQueries: I18n.t("gobierto_data.projects.buttonQueries") || "",
      labelButtonRecentQueries:
        I18n.t("gobierto_data.projects.buttonRecentQueries") || "",
      labelButtonRunQuery:
        I18n.t("gobierto_data.projects.buttonRunQuery") || "",
      removeLabelBtn: false,
      isQueriesModalActive: false,
      isRecentModalActive: false,
    };
  },
  watch: {
    $route(to, from) {
      if (to.path !== from.path) {
        this.showHideLabelIcons(true)
      }
    },
  },
  created() {
    // it has to be the same event (keydown) as SQLEditorCode
    document.addEventListener("keydown", this.keyboardShortcutsListener);

    if (this.$route.name === 'Query') {
      this.showHideLabelIcons(true)
    }
  },
  deactivated() {
    this.removeKeyboardListener()
  },
  methods: {
    keyboardShortcutsListener(e) {
      if (e.keyCode == 67) {
        // key "c"
        this.isQueriesModalActive ? this.closeQueriesModal() : this.openQueriesModal();

        // close the other modal, if open
        if (this.isRecentModalActive) {
          this.closeRecentModal()
        }
      } else if (e.keyCode == 82) {
        // key "r"
        this.isRecentModalActive ? this.closeRecentModal() : this.openRecentModal();

        // close the other modal, if open
        if (this.isQueriesModalActive) {
          this.closeQueriesModal()
        }
      } else if ((e.keyCode == 10 || e.keyCode == 13) && (e.ctrlKey || e.metaKey)) {
        this.clickRunQueryHandler();
      }
    },
    removeKeyboardListener() {
      document.removeEventListener("keydown", this.keyboardShortcutsListener);
    },
    onSaveEventHandler(opts) {
      const { name } = opts
      // if there's some name, shrink the other buttons
      this.removeLabelBtn = !!name

      // send the query to be stored
      this.$root.$emit("storeCurrentQuery", opts);
    },
    clickRunQueryHandler() {
      this.$root.$emit("runCurrentQuery");
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
    resetQuery() {
      this.$root.$emit('resetQuery', true)
      this.$root.$emit("hideLabelQueryModified", false);
    },
    revertQuery() {
      this.$root.$emit('revertSavedQuery', true)
      this.$root.$emit("hideLabelQueryModified", false);
    },
    showHideLabelIcons(value) {
      this.removeLabelBtn = value
    }
  },
};
</script>
