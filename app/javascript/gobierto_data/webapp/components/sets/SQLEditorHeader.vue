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
        <keep-alive>
          <transition
            name="fade"
            mode="out-in"
          >
            <RecentQueries
              v-show="isActive"
              :class="[
                directionLeft ? 'modal-left': 'modal-right',
                isActive ? 'active' : ''
              ]"
            />
          </transition>
        </keep-alive>
      </div>
      <div class="gobierto-data-sql-editor-your-queries">
        <button
          ref="button"
          :text="labelQueries"
          :class="removeLabelBtn ? 'remove-label' : ''"
          :disabled="disabledQueries"
          class="btn-sql-editor btn-sql-editor-queries gobierto-data-btn-blue"
          @click="isHidden = !isHidden"
        >
          <i
            style="color: inherit"
            class="fas fa-list"
          />
          {{ labelQueries }}
        </button>
        <keep-alive>
          <transition
            name="fade"
            mode="out-in"
          >
            <Queries
              v-closable="{
                exclude: ['button'],
                handler: 'closeYourQueries'
              }"
              v-show="!isHidden"
              v-closable="{
                exclude: ['button'],
                handler: 'closeYourQueries'
              }"
              :array-queries="arrayQueries"
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
          v-model="labelQueryName"
          type="text"
          class="gobierto-data-sql-editor-container-save-text"
          @keyup="onSave($event.target.value)"
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
import { getToken } from './../../../lib/helpers'
import { baseUrl, CommonsMixin, closableMixin } from "./../../../lib/commons.js";
import axios from 'axios';
import Button from './../commons/Button.vue';
import RecentQueries from './RecentQueries.vue';
import Queries from './Queries.vue';

let handleOutsideClick
export default {
  name: 'SQLEditorHeader',
  components: {
    Button,
    RecentQueries,
    Queries
  },
<<<<<<< HEAD
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
    },
    closable : {
      bind (el, binding, vnode) {
        handleOutsideClick = (e) => {
          e.stopPropagation()
          const { handler, exclude } = binding.value
          let clickedOnExcludedEl = false
          exclude.forEach(refName => {
            if (!clickedOnExcludedEl) {
              const excludedEl = vnode.context.$refs[refName]
              clickedOnExcludedEl = excludedEl.contains(e.target)
            }
          })
          if (!el.contains(e.target) && !clickedOnExcludedEl) {
            vnode.context[handler]()
          }
        }
        document.addEventListener('click', handleOutsideClick)
        document.addEventListener('touchstart', handleOutsideClick)
      },
      unbind () {
        document.removeEventListener('click', handleOutsideClick)
        document.removeEventListener('touchstart', handleOutsideClick)
      }
    }
  },
=======
  mixins: [CommonsMixin, closableMixin],
>>>>>>> a7572afeb28d10ca8590033e2b35083196aa5591
  props: {
    arrayQueries: {
      type: Array,
      required: true
    },
    datasetId: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      showStoreQueries: [],
      disabledRecents: false,
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
      codeQuery: '',
      endPoint: '',
      privacyStatus: '',
      propertiesQueries: [],
      directionLeft: true,
      url: '',
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

    this.$root.$on('sendQueryCode', this.updateQuery)
    this.$root.$on('activeSave', this.activeSave);
    this.$root.$on('sendCode', this.updateQuery);
    this.$root.$on('updateActiveSave', this.updateActiveSave);
    this.$root.$on('storeQuery', this.showshowStoreQueries)
    this.$root.$on('sendQueryParams', this.queryParams)
    this.$root.$on('sendYourQuery', this.runYourQuery)

<<<<<<< HEAD
    this.$root.$on('closeQueriesModal', this.closeYourQueries);
=======
    this.$root.$on('closeQueriesModal', this.closeYourQueries)

>>>>>>> a7572afeb28d10ca8590033e2b35083196aa5591

    this.token = getToken()
  },
  methods: {
    onSave(queryName) {
      this.disabledSave = false
      this.labelQueryName = queryName
    },
    runYourQuery(code) {
      this.queryEditor = code
      this.runQuery()
    },
    queryParams(queryParams) {
<<<<<<< HEAD
      this.showSaveQueries = true
      this.showBtnCancel = true;
      this.showBtnEdit = false;
      this.showBtnSave = true;
      this.showBtnRemove = false;
      this.showLabelPrivate = true;
      this.removeLabelBtn = true;
      this.showLabelModified = false;
      this.disableInputName = false;
      this.saveQueryState = true
=======
      this.saveQueryState = true;
      this.showBtnCancel = false;
      this.showBtnSave = false;
      this.disabledRecents = false;
      this.disabledSave = true;
      this.showBtnEdit = true;
      this.removeLabelBtn = true;
      this.showLabelPrivate = false;
      this.disableInputName = true;
      this.$root.$emit('saveQueryState', true);
>>>>>>> a7572afeb28d10ca8590033e2b35083196aa5591

      this.labelQueryName = queryParams[0]
      this.privacyStatus = queryParams[1]
      this.codeQuery = queryParams[2]

      if (this.privacyStatus === 'open') {
        this.privateQuery = false
      } else {
        this.privateQuery = true
      }

    },
    privateQueryValue(valuePrivate) {
      this.disabledSave = false
      this.privateQuery = valuePrivate
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
    privateQueryValue(valuePrivate) {
      this.disabledSave = false
      this.privateQuery = valuePrivate
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
    runQuery() {
      this.showSpinner = true;
      this.queryEditor = encodeURI(this.codeQuery)

      if (this.queryEditor.includes('LIMIT')) {
        this.queryEditor = this.queryEditor
      } else {
        this.$root.$emit('sendCompleteQuery', this.queryEditor)
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
        this.queryEditor = this.code
      }

      this.$root.$emit('postRecentQuery', this.codeQuery)
      this.$root.$emit('showMessages', false)

      this.endPoint = `${baseUrl}/data`
      this.url = `${this.endPoint}?sql=${this.queryEditor}`

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
    postQuery() {
      this.endPoint = `${baseUrl}/queries`
      this.privacyStatus = this.privateQuery === false ? 'open' : 'closed'
      let data = {
          "data": {
              "type": "gobierto_data-queries",
              "attributes": {
                  "name": this.labelQueryName,
                  "privacy_status": this.privacyStatus,
                  "sql": this.codeQuery,
                  "dataset_id": this.datasetId
              }
          }
      }
      axios.post(this.endPoint, data, {
        headers: {
          'Content-type': 'application/json',
          'Authorization': `${this.token}`
        }
      }).then(response => {
          this.resp = response;
          this.$root.$emit('reloadQueries')
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
}
</script>
