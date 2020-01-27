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
      <div class="gobierto-data-sql-editor-container-recent-queries">
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
          v-if="showStoreQueries"
          :class="[
            directionLeft ? 'modal-left': 'modal-right',
            isActive ? 'active' : ''
          ]"
        />
      </div>
      <div class="gobierto-data-sql-editor-your-queries">
        <Button
          v-clickoutside="closeYourQueries"
          :text="labelQueries"
          :class="removeLabelBtn ? 'remove-label' : ''"
          :disabled="disabledQueries"
          class="btn-sql-editor"
          icon="list"
          color="var(--color-base)"
          background="#fff"
          @click.native="isHidden = !isHidden; listYourQueries()"
        />
        <keep-alive>
          <transition
            name="fade"
            mode="out-in"
          >
            <Queries
              v-show="!isHidden"
              :class=" directionLeft ? 'modal-left': 'modal-right'"
              class="gobierto-data-sql-editor-your-queries-container arrow-top"
            />
          </transition>
        </keep-alive>
      </div>
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
      >
        <div
          v-if="showSpinner"
          class="spinner-box"
        >
          <div class="pulse-container">
            <div class="pulse-bubble pulse-bubble-1" />
            <div class="pulse-bubble pulse-bubble-2" />
            <div class="pulse-bubble pulse-bubble-3" />
          </div>
        </div>
      </Button>
    </div>
  </div>
</template>
<script>
import getToken from './../../../lib/helpers';
import axios from 'axios';
import Button from './../commons/Button.vue';
import RecentQueries from './RecentQueries.vue';
import Queries from './Queries.vue';

export default {
  name: 'SQLEditorHeader',
  components: {
    Button,
    RecentQueries,
    Queries
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
      showStoreQueries: [],
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
      isHidden: true,
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
      propertiesQueries: [],
      directionLeft: true,
      url: '',
      urlPath: '',
      showSpinner: false,
      token: ''
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
    this.$root.$on('sendCode', this.updateQuery);
    this.$root.$on('updateActiveSave', this.updateActiveSave);
    this.$root.$on('storeQuery', this.showshowStoreQueries)
    this.$root.$on('sendQueryParams', this.queryParams)

    this.token = getToken()
  },
  methods: {
    queryParams(queryParams) {
      this.showBtnCancel = false;
      this.showBtnEdit = true;
      this.showBtnSave = false;
      this.showBtnRemove = false;
      this.showLabelPrivate = false;
      this.removeLabelBtn = true;
      this.showLabelModified = false;
      this.disableInputName = true;
      this.saveQueryState = true;

      this.labelQueryName = queryParams[0]
      this.privacyStatus = queryParams[1]

      if (this.privacyStatus === 'open') {
        this.privateQuery = false
      } else {
        this.privateQuery = true
      }
    },
    listYourQueries() {
      this.$root.$emit('listYourQueries')
    },
    showshowStoreQueries(queries) {
      this.$root.$emit('showRecentQueries', queries)
    },
    activeSave(value) {
      this.disabledRecents = value;
      this.disabledSave = value;
      this.disabledRunQuery = value;
    },
    updateQuery(code) {
      this.codeQuery = code;
    },
    updateActiveSave(activeLabel, disableLabel) {
      this.showLabelModified = activeLabel;
      this.showBtnSave = activeLabel;
      this.showBtnEdit = disableLabel;
      this.disableInputName = disableLabel;
    },
    saveQueryName() {
      this.showSaveQueries = true
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
      this.showSpinner = true;
      this.queryEditor = encodeURI(this.codeQuery)
      this.$root.$emit('postRecentQuery', this.codeQuery)
      this.$root.$emit('showMessages', false)

      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/data';
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`

      axios
        .get(this.url)
        .then(response => {
          this.data = []
          this.keysData = []
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.data = this.rawData.data

          this.queryDurationRecors = [this.meta.rows, this.meta.duration]

          this.keysData = Object.keys(this.data[0])

          this.$root.$emit('recordsDuration', this.queryDurationRecors)
          this.$root.$emit('sendData', this.keysData, this.data)
          this.$root.$emit('showMessages', true)

        })
        .catch(error => {
          const messageError = error.response.data.errors[0].sql
          this.$root.$emit('apiError', messageError)

          this.data = []
          this.keysData = []
          this.$root.$emit('sendData', this.keysData, this.data)

        })

        setTimeout(() => {
          this.showSpinner = false
        }, 300)
    },
    recentQueries() {
      this.isActive = !this.isActive;
    },
    closeMenu() {
      this.isActive = false
    },
    closeYourQueries() {
      this.isHidden = true
    },
    deleteQuery(index) {
      const URL = `/api/v1/data/queries/${index}`
      axios.delete(URL, {
        headers: {
          'Content-type': 'application/json',
          'Authorization': `${this.token}`
        }
      });
    },
    postQuery() {


      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/queries'
      this.url = `${this.urlPath}${this.endPoint}`
      this.privacyStatus = this.privateQuery === false ? 'open' : 'closed'

      let data = {
          "data": {
              "type": "gobierto_data-queries",
              "attributes": {
                  "name": this.nameQuery,
                  "name_translations": {
                      "en": this.nameQuery,
                      "es": this.nameQuery
                  },
                  "privacy_status": this.privacyStatus,
                  "sql": this.codeQuery,
                  "dataset_id": 1
              }
          }
      }
      axios.post(this.url, data, {
        headers: {
          'Content-type': 'application/json',
          'Authorization': `${this.token}`
        }
      }).then(response => {
          this.resp = response;
      })
      .catch(error => {
        const messageError = error.response
        console.error(messageError)
      });
    },
    runRecentQuery(code) {
      this.codeQuery = code
      this.runQuery()
    }
  }
};
</script>
