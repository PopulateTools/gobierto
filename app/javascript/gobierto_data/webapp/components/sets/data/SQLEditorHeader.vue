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
            :class="[
              directionLeft ? 'modal-left': 'modal-right',
              isRecentModalActive ? 'active' : ''
            ]"
          />
        </transition>
        <!-- <keep-alive /> -->
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
            :class=" directionLeft ? 'modal-left': 'modal-right'"
            class="gobierto-data-sets-nav--tab-container gobierto-data-sql-editor-your-queries-container arrow-top"
          />
        </transition>
      </div>

      <div
        v-if="saveQueryState"
        class="gobierto-data-sql-editor-container-save"
      >
        <input
          ref="inputText"
          v-model="labelQueryName"
          :class="disableInputName ? 'disable-input-text' : ' '"
          type="text"
          class="gobierto-data-sql-editor-container-save-text"
          @keyup="onSave($event.target.value)"
          @focus="onFocusEditor"
        >
        <input
          v-if="showLabelPrivate"
          :id="labelPrivate"
          :checked="privateQuery"
          type="checkbox"
          class="gobierto-data-sql-editor-container-save-checkbox"
          @input="privateQueryValue($event.target.checked)"
        >
        <label
          v-if="showLabelPrivate"
          :for="labelPrivate"
          class="gobierto-data-sql-editor-container-save-label"
        >
          {{ labelPrivate }}
        </label>
        <i
          :class="privateQuery ? 'fa-lock' : 'fa-lock-open'"
          :style="privateQuery ? 'color: #D0021B;' : 'color: #A0C51D;'"
          class="fas"
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
        :text="labelSave"
        :style="
          saveQueryState
            ? 'color: #fff; background-color: var(--color-base)'
            : 'color: var(--color-base); background-color: rgb(255, 255, 255);'
        "
        class="btn-sql-editor"
        icon="save"
        color="var(--color-base)"
        background="#fff"
        @click.native="userLogged()"
      />

      <Button
        v-if="showBtnCancel"
        :text="labelCancel"
        class="btn-sql-editor btn-sql-editor-cancel"
        icon="undefined"
        color="var(--color-base)"
        background="#fff"
        @click.native="cancelQuery()"
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
        <PulseSpinner v-if="showSpinner" />
      </Button>
    </div>
  </div>
</template>
<script>
import { getUserId } from './../../../../lib/helpers'
import { CommonsMixin, closableMixin } from "./../../../../lib/commons.js";

import Button from './../../commons/Button.vue';
import Queries from './../../commons/Queries.vue';
import PulseSpinner from './../../commons/PulseSpinner.vue';
import RecentQueries from './RecentQueries.vue';

export default {
  name: 'SQLEditorHeader',
  components: {
    Button,
    RecentQueries,
    Queries,
    PulseSpinner
  },
  mixins: [CommonsMixin, closableMixin],
  props: {
    privateQueries: {
      type: Array,
      default: () => []
    },
    publicQueries: {
      type: Array,
      default: () => []
    },
    tableName: {
      type: String,
      default: ''
    },
    queryName: {
      type: String,
      default: null
    },
  },
  data() {
    return {
      labelSave: I18n.t('gobierto_data.projects.save') || '',
      labelRecents: I18n.t('gobierto_data.projects.recents') || '',
      labelQueries: I18n.t('gobierto_data.projects.queries') || '',
      labelRunQuery: I18n.t('gobierto_data.projects.runQuery') || '',
      labelCancel: I18n.t('gobierto_data.projects.cancel') || '',
      labelPrivate: I18n.t('gobierto_data.projects.private') || '',
      labelQueryName: this.queryName || I18n.t('gobierto_data.projects.queryName') || '',
      labelEdit: I18n.t('gobierto_data.projects.edit') || '',
      labelModifiedQuery: I18n.t('gobierto_data.projects.modifiedQuery') || '',
      labelButtonQueries: I18n.t('gobierto_data.projects.buttonQueries') || '',
      labelButtonRecentQueries: I18n.t('gobierto_data.projects.buttonRecentQueries') || '',
      labelButtonRunQuery: I18n.t('gobierto_data.projects.buttonRunQuery') || '',
      disableInputName: false,
      saveQueryState: false,
      privateQuery: false,
      showBtnCancel: false,
      showBtnEdit: false,
      showBtnSave: true,
      showBtnRemove: true,
      showLabelPrivate: true,
      removeLabelBtn: false,
      showLabelModified: false,
      isQueriesModalActive: false,
      isRecentModalActive: false,
      directionLeft: true,
      showSpinner: false,
      noLogin: false,
    }
  },
  created() {
    this.$root.$on('updateActiveSave', this.updateActiveSave);

    this.userId = getUserId()
    this.noLogin = this.userId === "" ? true : false

    this.$root.$on('blurEditor', this.onBlurEditor)
    this.$root.$on('focusEditor', this.onFocusEditor)

    // Allow the shortcuts at startup
    this.onBlurEditor()
  },
  beforeDestroy() {
    this.$root.$off('updateActiveSave', this.updateActiveSave);
    this.$root.$off('blurEditor', this.onBlurEditor)
    this.$root.$off('focusEditor', this.onFocusEditor)
  },
  methods: {
    modalShortcutsListener(e) {
      if (e.keyCode == 67) {
        // key "c"
        this.openQueriesModal()
      } else if (e.keyCode == 82) {
        // key "r"
        this.openRecentModal()
      }
    },
    editorShortcutsListener(e) {
      if ((e.keyCode == 10 || e.keyCode == 13) && e.ctrlKey) {
        this.clickRunQueryHandler()
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
      this.disabledSave = false
      this.labelQueryName = queryName
    },
    userLogged() {
      if (this.noLogin)
        this.goToLogin()
      else
        this.saveQueryName()
    },
    goToLogin() {
      location.href='/user/sessions/new?open_modal=true'
    },
    privateQueryValue(valuePrivate) {
      this.disabledSave = false
      this.privateQuery = valuePrivate
      this.showLabelModified = true
      this.showBtnSave = true
      this.showBtnEdit = false
    },
    showStoreQueries(queries) {
      this.$root.$emit('showRecentQueries', queries)
    },
    updateActiveSave(activeLabel, disableLabel) {
      this.showLabelModified = activeLabel
      this.showLabelPrivate = activeLabel
      this.showBtnSave = activeLabel
      this.showBtnEdit = disableLabel
      this.disableInputName = disableLabel
    },
    saveQueryName() {
      this.showSaveQueries = true
      if (this.saveQueryState === true && this.labelQueryName.length > 0) {
        this.showBtnCancel = false;
        this.showBtnEdit = true;
        this.showBtnSave = false;
        this.showBtnRemove = false;
        this.showLabelPrivate = false;
        this.removeLabelBtn = true;
        this.showLabelModified = false;
        this.disableInputName = true;

        this.clickSaveQueryHandler()
      } else {
        this.saveQueryState = true;
        this.showBtnCancel = true;
        this.setFocus();
        this.$root.$emit('saveQueryState', true);
      }
    },
    setFocus() {
      this.$nextTick(() => {
        this.$refs.inputText.focus();
      });
    },
    cancelQuery() {
      if (this.labelQueryName.length > 0) {
        this.showBtnCancel = false;
        this.showBtnEdit = true;
        this.showBtnSave = false;
        this.showBtnRemove = false;
        this.showLabelPrivate = false;
        this.removeLabelBtn = true;
        this.showLabelModified = false;
        this.disableInputName = true;

      } else {
        this.showBtnCancel = false;
        this.showBtnEdit = false;
        this.showBtnSave = true;
        this.showBtnRemove = true;
        this.showLabelPrivate = true;
        this.removeLabelBtn = false;
        this.saveQueryState = false;
      }
    },
    clickRunQueryHandler() {
      this.$root.$emit('runCurrentQuery')
    },
    clickSaveQueryHandler() {
      this.$root.$emit('storeCurrentQuery', { name: this.labelQueryName, privacy: this.privateQuery })
    },
    clickEditQueryHandler() {
      this.setFocus();
      this.showBtnCancel = true;
      this.showBtnEdit = false;
      this.showBtnSave = true;
      this.showBtnRemove = true;
      this.showLabelPrivate = true;
      this.removeLabelBtn = false;
      this.disableInputName = false;
    },
    openRecentModal() {
      this.isRecentModalActive = true
    },
    closeRecentModal() {
      this.isRecentModalActive = false
    },
    openQueriesModal() {
      this.isQueriesModalActive = true
    },
    closeQueriesModal() {
      this.isQueriesModalActive = false
    },
    //     queryParams(queryParams) {
    //   this.saveQueryState = true
    //   this.showBtnCancel = false
    //   this.showBtnSave = false
    //   this.disabledRecents = false
    //   this.disabledSave = true
    //   this.showBtnEdit = true
    //   this.removeLabelBtn = true
    //   this.showLabelPrivate = false
    //   this.disableInputName = true
    //   this.showLabelModified = false
    //   this.$root.$emit('saveQueryState', true)

    //   this.labelQueryName = queryParams[0]
    //   this.oldQueryName = queryParams[0]
    //   this.privacyStatus = queryParams[1]
    //   this.codeQuery = queryParams[2]
    //   this.queryId = parseInt(queryParams[3])
    //   this.userIdQuery = queryParams[4].toString()

    //   if (this.privacyStatus === 'open') {
    //     this.privateQuery = false
    //   } else {
    //     this.privateQuery = true
    //   }
    // },
  }
}
</script>
