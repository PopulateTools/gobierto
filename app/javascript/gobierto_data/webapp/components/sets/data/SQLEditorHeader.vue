<template>
  <div class="gobierto-data-sql-editor-toolbar">
    <div class="gobierto-data-sql-editor-container">
      <Button
        :title="labelResetQuery"
        class="btn-sql-editor"
        icon="home"
        background="#fff"
        @click.native="resetQueryHandler"
        @enabledInput="enabledInputQueries"
      />
    </div>
    <div class="gobierto-data-sql-editor-container">
      <Button
        v-clickoutside="closeRecentModal"
        :class="{ 'remove-label' : removeLabelBtn }"
        :title="labelButtonRecentQueries"
        class="btn-sql-editor"
        icon="history"
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
      <!-- //Closable directive doesn't work with component, so i've used the html attribute :\ -->
      <button
        ref="buttonYourQueries"
        class="btn-sql-editor btn-sql-editor-queries gobierto-data-btn-blue"
        :aria-label="labelYourQueries"
        @click="isQueriesModalActive = !isQueriesModalActive"
      >
        <i
          style="color: inherit"
          class="fas fa-list"
        />
      </button>

      <transition
        name="fade"
        mode="out-in"
      >
        <Queries
          v-show="isQueriesModalActive"
          v-closable="{
            exclude: ['buttonYourQueries'],
            handler: 'closeQueriesModal'
          }"
          :private-queries="privateQueries"
          :public-queries="publicQueries"
          :is-user-logged="isUserLogged"
          class="gobierto-data-sets-nav--tab-container gobierto-data-sql-editor-your-queries-container arrow-top"
          @closeQueriesModal="closeQueriesModal"
        />
      </transition>
    </div>
    <SavingDialog
      ref="savingDialogQuery"
      :placeholder="labelQueryName"
      :value="queryName"
      :label-saved="labelSaved"
      :label-modified="labelModifiedQuery"
      :is-query-modified="isQueryModified"
      :is-query-saved="isQuerySaved"
      :is-fork-prompt-visible="isForkPromptVisible"
      :is-user-logged="isUserLogged"
      :enabled-fork-button="enabledForkButton"
      :enabled-revert-button="enabledRevertButton"
      :is-query-saving-prompt-visible="isQuerySavingPromptVisible"
      :enabled-query-saved-button="enabledQuerySavedButton"
      :show-revert-query="showRevertQuery"
      :show-private="showPrivate"
      :show-private-public-icon="showPrivatePublicIcon"
      :reset-private="resetPrivate"
      @save="saveHandlerSavedQuery"
      @keyDownInput="updateQueryName"
      @handlerFork="handlerForkQuery"
      @isPrivateChecked="isPrivateChecked"
    />

    <Button
      :text="labelRunQuery"
      :title="labelButtonRunQuery"
      class="btn-sql-editor btn-sql-editor-run"
      icon="play"
      background="#fff"
      @click.native="clickRunQueryHandler()"
    >
      <PulseSpinner v-if="isQueryRunning" />
    </Button>
  </div>
</template>
<script>
import { VueDirectivesMixin } from "lib/vue/directives";
import { closableMixin } from "./../../../../lib/commons.js";
import { tabs } from '../../../../lib/router';

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
  mixins: [VueDirectivesMixin, closableMixin],
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
    isQuerySavingPromptVisible: {
      type: Boolean,
      default: false
    },
    isForkPromptVisible: {
      type: Boolean,
      default: true
    },
    isQueryModified: {
      type: Boolean,
      default: false
    },
    queryName: {
      type: String,
      default: '',
    },
    enabledQuerySavedButton: {
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
    enabledForkButton: {
      type: Boolean,
      default: false
    },
    enabledRevertButton: {
      type: Boolean,
      default: false
    },
    isUserLogged: {
      type: Boolean,
      default: false
    },
    queryInputFocus: {
      type: Boolean,
      default: false
    },
    showPrivatePublicIcon: {
      type: Boolean,
      default: false
    },
    resetPrivate: {
      type: Boolean,
      default: false
    },
    registrationDisabled: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelRecents: I18n.t("gobierto_data.projects.recents") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelYourQueries: I18n.t("gobierto_data.projects.yourQueries") || "",
      labelRunQuery: I18n.t("gobierto_data.projects.runQuery") || "",
      labelResetQuery: I18n.t("gobierto_data.projects.resetQuery") || "",
      labelSaved: I18n.t("gobierto_data.projects.savedQuery") || "",
      labelQueryName: I18n.t("gobierto_data.projects.queryName") || "",
      labelButtonQueries: I18n.t("gobierto_data.projects.buttonQueries") || "",
      labelModifiedQuery: I18n.t("gobierto_data.projects.modifiedQuery") || "",
      labelButtonRecentQueries:
        I18n.t("gobierto_data.projects.buttonRecentQueries") || "",
      labelButtonRunQuery:
        I18n.t("gobierto_data.projects.buttonRunQuery") || "",
      removeLabelBtn: false,
      isQueriesModalActive: false,
      isRecentModalActive: false,
      labelValue: this.queryName,
    };
  },
  watch: {
    queryInputFocus(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.$nextTick(() => this.$refs.savingDialogQuery.inputFocus(newValue))
      }
    }
  },
  created() {
    // it has to be the same event (keydown) as SQLEditorCode
    document.addEventListener("keydown", this.keyboardShortcutsListener);
  },
  deactivated() {
    this.$destroy()
  },
  beforeDestroy() {
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
    updateQueryName(value) {
      const {
        name: queryName
      } = value;
      this.labelValue = queryName
      this.$root.$emit('enableSavedButton')
    },
    saveHandlerSavedQuery(opts) {
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
    resetQueryHandler() {
      this.$root.$emit('resetQuery')
      this.$router.push(
        `/datos/${this.$route.params.id}/${tabs[1]}`
      //Avoid errors when user goes to the same route
      // eslint-disable-next-line no-unused-vars
      ).catch(err => {})
    },
    enabledInputQueries() {
      if (!this.enabledForkButton && this.isUserLogged) {
        this.$root.$emit('eventToEnabledInputQueries')
        this.$nextTick(() => this.$refs.savingDialogQuery.inputFocus());
      }
    },
    handlerForkQuery() {
      this.$nextTick(() => {
        this.$refs.savingDialogQuery.inputFocus()
        this.$refs.savingDialogQuery.inputSelect()
      });
      this.$root.$emit('enableSavedButton')
      this.$root.$emit('enabledForkPrompt')
      this.$root.$emit('enabledRevertButton')
      this.$root.$emit('disabledForkButton')
    },
    isPrivateChecked() {
      this.$root.$emit('eventIsQueryModified', true)
    }
  },
};
</script>
