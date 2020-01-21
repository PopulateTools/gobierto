<template>
  <div>
    <div class="gobierto-data-sql-editor-toolbar">
      <!-- <Button
        v-if="showBtnRemove"
        :text="undefined"
        class="btn-sql-editor"
        icon="times"
        color="var(--color-base)"
        background="#fff"
      /> -->
      <div style="display: inline-block; position: relative;">
        <Button
          v-clickoutside="closeMenu"
          :text="labelRecents"
          :class="removeLabelBtn ? 'remove-label' : ''"
          :disabled="disabledRecents"
          class="btn-sql-editor"
          icon="history"
          color="var(--color-base)"
          background="#fff"
          @click.native="recentQueries()"
        />
        <RecentQueries
          v-if="storeQueries"
          :class="{ 'active': isActive }"
        />
      </div>
      <Button
        :text="labelQueries"
        :class="removeLabelBtn ? 'remove-label' : ''"
        :disabled="disabledQueries"
        class="btn-sql-editor"
        icon="list"
        color="var(--color-base)"
        background="#fff"
      />
      <div
        v-if="saveQueryState"
        class="gobierto-data-sql-editor-container-save"
      >
        <input
          ref="inputText"
          :class="disableInputName ? 'disable-input-text' : ' '"
          :placeholder="labelQueryName"
          type="text"
          class="gobierto-data-sql-editor-container-save-text"
          @keyup="nameQuery = $event.target.value"
        >
        <input
          v-if="showLabelPrivate"
          :id="labelPrivate"
          :checked="privateQuery"
          type="checkbox"
          class="gobierto-data-sql-editor-container-save-checkbox"
          @input="privateQuery = $event.target.checked"
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
          style="color: #A0C51D;"
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
        :disabled="disabledSave"
        class="btn-sql-editor"
        icon="save"
        color="var(--color-base)"
        background="#fff"
        @click.native="saveQueryName()"
      />
      <Button
        v-if="showBtnCancel"
        :text="labelCancel"
        class="btn-sql-editor"
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
        @click.native="editQuery()"
      />
      <Button
        v-if="showBtnRun"
        :text="labelRunQuery"
        :disabled="disabledRunQuery"
        class="btn-sql-editor btn-sql-editor-run"
        icon="play"
        color="var(--color-base)"
        background="#fff"
        @click.native="runQuery()"
      />
    </div>
  </div>
</template>
<script>
import axios from 'axios';
import Button from './../commons/Button.vue';
import RecentQueries from './RecentQueries.vue';

export default {
  name: 'SQLEditorHeader',
  components: {
    Button,
    RecentQueries
  },
  directives: {
    clickoutside: {
      bind: function(el, binding, vnode) {
        el.clickOutsideEvent = function(event) {
          if (!(el == event.target || el.contains(event.target))) {
            vnode.context[binding.expression](event);
          }
        };
        document.body.addEventListener('click', el.clickOutsideEvent)
      },
      unbind: function(el) {
        document.body.removeEventListener('click', el.clickOutsideEvent)
      },
      stopProp(event) { event.stopPropagation() }
    }
  },
  data() {
    return {
      storeQueries: [],
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
      showActiveRecent: false,
      isActive: false,
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
      codeQuery: '',
      endPoint: '',
      privacyStatus: '',
      propertiesQueries: []
    }
  },
  created() {
    this.labelSave = I18n.t('gobierto_data.projects.save');
    this.labelRecents = I18n.t('gobierto_data.projects.recents');
    this.labelQueries = I18n.t('gobierto_data.projects.queries');
    this.labelRunQuery = I18n.t('gobierto_data.projects.runQuery');
    this.labelCancel = I18n.t('gobierto_data.projects.cancel');
    this.labelPrivate = I18n.t('gobierto_data.projects.private');
    this.labelQueryName = I18n.t('gobierto_data.projects.queryName');
    this.labelEdit = I18n.t('gobierto_data.projects.edit');
    this.labelModifiedQuery = I18n.t('gobierto_data.projects.modifiedQuery');
    this.labelGuide = I18n.t('gobierto_data.projects.guide');

    this.$root.$on('activeSave', this.activeSave);
    this.$root.$on('updateCode', this.updateQuery);
    this.$root.$on('updateActiveSave', this.updateActiveSave);
    this.$root.$on('storeQuery', this.showStoreQueries)
  },
  methods: {
    showStoreQueries(value) {
      this.$root.$emit('showRecentQueries', value)
    },
    activeSave(value) {
      this.disabledRecents = value;
      this.disabledSave = value;
      this.disabledRunQuery = value;
    },
    updateQuery(value) {
      this.codeQuery = value;
    },
    updateActiveSave(activeLabel, disableLabel) {
      this.showLabelModified = activeLabel;
      this.showBtnSave = activeLabel;
      this.showBtnEdit = disableLabel;
      this.disableInputName = disableLabel;
    },
    saveQueryName() {
      if (this.saveQueryState === true && this.nameQuery.length > 0) {
        this.showBtnCancel = false;
        this.showBtnEdit = true;
        this.showBtnSave = false;
        this.showBtnRemove = false;
        this.showLabelPrivate = false;
        this.removeLabelBtn = true;
        this.showLabelModified = false;
        this.disableInputName = true;

        this.postQuery()

        this.propertiesQueries = [ this.nameQuery, this.codeQuery, this.privacyStatus]
        this.$root.$emit('saveYourQueries', this.propertiesQueries)
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
    editQuery() {
      this.setFocus();
      this.showBtnCancel = true;
      this.showBtnEdit = false;
      this.showBtnSave = true;
      this.showBtnRemove = true;
      this.showLabelPrivate = true;
      this.removeLabelBtn = false;
      this.disableInputName = false;
    },
    cancelQuery() {
      if (this.nameQuery.length > 0) {
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
    runQuery() {
      let oneLine = this.codeQuery.replace(/\n/g, ' ');
      this.codeQuery = oneLine.replace(/  +/g, ' ');
      this.$root.$emit('updateCodeQuery', this.codeQuery)
      this.$root.$emit('showMessages', true)
    },
    recentQueries() {
      this.isActive = !this.isActive;
    },
    closeMenu() {
      this.isActive = false
    },
    postQuery() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/queries'
      this.url = `${this.urlPath}${this.endPoint}`
      this.privacyStatus = this.privateQuery === false ? 'close' : 'open'

      let data = {
          "data": {
              "type": "gobierto_data-queries",
              "attributes": {
                  "name": this.nameQuery,
                  "name_translations": {
                      "en": "Query from API",
                      "es": "Query desde la API"
                  },
                  "privacy_status": this.privacyStatus,
                  "sql": this.codeQuery,
                  "dataset_id": 1,
                  "user_id": 90
              }
          }
      }
      axios.post(this.url, data, {
        headers: {
          'Content-type': 'application/json',
        }
      }).then(response => {
          this.resp = response;
      })
      .catch(e => {
          console.error(e);
      });
    }
  }
};
</script>
