<template>
  <div>
    <div class="gobierto-data-sql-editor-toolbar">
      <div class="gobierto-data-sql-editor-container-recent-queries">
        <Button
          v-clickoutside="closeMenu"
          :text="labelRecents"
          :class="removeLabelBtn ? 'remove-label' : ''"
          :disabled="disabledRecents"
          :title="labelButtonRecentQueries"
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
              :table-name="tableName"
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
          :title="labelButtonQueries"
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
              v-show="!isHidden"
              v-closable="{
                exclude: ['button'],
                handler: 'closeQueriesModal'
              }"
              :private-queries="privateQueries"
              :public-queries="publicQueries"
              :dataset-id="datasetId"
              :class=" directionLeft ? 'modal-left': 'modal-right'"
              tabindex="-1"
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
          v-model="labelQueryName"
          :class="disableInputName ? 'disable-input-text' : ' '"
          type="text"
          class="gobierto-data-sql-editor-container-save-text"
          @keyup="onSave($event.target.value)"
          @focus="removeShortcutsListener"
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
        @click.native="editQuery()"
      />
      <Button
        v-if="showBtnRun"
        :text="labelRunQuery"
        :disabled="disabledRunQuery"
        :title="labelButtonRunQuery"
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
import { getToken, getUserId } from './../../../lib/helpers'
import { baseUrl, CommonsMixin, closableMixin } from "./../../../lib/commons.js";
import { DataFactoryMixin } from "./../../../lib/factories/data";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
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
  mixins: [CommonsMixin, closableMixin, DataFactoryMixin, QueriesFactoryMixin],
  props: {
    privateQueries: {
      type: Array,
      default: () => []
    },
    publicQueries: {
      type: Array,
      default: () => []
    },
    datasetId: {
      type: Number,
      required: true
    },
    tableName: {
      type: String,
      default: ''
    },
    numberRows: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      labelSave: I18n.t('gobierto_data.projects.save') || '',
      labelRecents: I18n.t('gobierto_data.projects.recents') || '',
      labelQueries: I18n.t('gobierto_data.projects.queries') || '',
      labelRunQuery: I18n.t('gobierto_data.projects.runQuery') || '',
      labelCancel: I18n.t('gobierto_data.projects.cancel') || '',
      labelPrivate: I18n.t('gobierto_data.projects.private') || '',
      labelQueryName: I18n.t('gobierto_data.projects.queryName') || '',
      labelEdit: I18n.t('gobierto_data.projects.edit') || '',
      labelModifiedQuery: I18n.t('gobierto_data.projects.modifiedQuery') || '',
      labelButtonQueries: I18n.t('gobierto_data.projects.buttonQueries') || '',
      labelButtonRecentQueries: I18n.t('gobierto_data.projects.buttonRecentQueries') || '',
      labelButtonRunQuery: I18n.t('gobierto_data.projects.buttonRunQuery') || '',
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
      codeQuery: '', // Deprecated
      privacyStatus: '',
      directionLeft: true,
      showSpinner: false,
      token: '',
      noLogin: false,
      editorFocus: false,
      queryId: '',
      userIdQuery: '',
      oldQueryName: '',
    }
  },
  created() {
    this.$root.$on('sendQueryParams', this.queryParams)
    this.$root.$on('activeSave', this.activeSave);
    this.$root.$on('updateActiveSave', this.updateActiveSave);
    this.$root.$on('storeQuery', this.showStoreQueries)
    this.$root.$on('closeQueriesModal', this.closeQueriesModal)
    this.$root.$on('disableEdit', this.hideEdit)
    this.$root.$on('blurEditor', this.activateShortcutsListener)
    this.$root.$on('focusEditor', this.removeShortcutsListener)

    this.token = getToken()
    this.userId = getUserId()
    this.noLogin = this.userId === "" ? true : false
    this.codeQuery = `SELECT%20*%20FROM%20${this.tableName}%20`

    this.activateShortcutsListener()

    window.addEventListener('keydown', e => {
      if (e.metaKey && e.keyCode == 13) {
        this.runQuery()
      }
    })
  },
  methods: {
    shortcutsListener(e) {
      if (e.keyCode == 67) {
        this.openYourQueries()
      } else if (e.keyCode == 82) {
        this.showRecentQueries()
      }
    },
    activateShortcutsListener() {
      window.addEventListener("keydown", this.shortcutsListener, true);
    },
    removeShortcutsListener() {
      window.removeEventListener("keydown", this.shortcutsListener, true);
    },
    hideEdit(){
      this.showBtnEdit = false
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
    queryParams(queryParams) {
      this.saveQueryState = true
      this.showBtnCancel = false
      this.showBtnSave = false
      this.disabledRecents = false
      this.disabledSave = true
      this.showBtnEdit = true
      this.removeLabelBtn = true
      this.showLabelPrivate = false
      this.disableInputName = true
      this.showLabelModified = false
      this.$root.$emit('saveQueryState', true)

      this.labelQueryName = queryParams[0]
      this.oldQueryName = queryParams[0]
      this.privacyStatus = queryParams[1]
      this.codeQuery = queryParams[2]
      this.queryId = parseInt(queryParams[3])
      this.userIdQuery = queryParams[4].toString()

      if (this.privacyStatus === 'open') {
        this.privateQuery = false
      } else {
        this.privateQuery = true
      }
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
    activeSave(value) {
      this.disabledRecents = value
      this.disabledSave = value
      this.disabledRunQuery = value
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
      this.$root.$emit('runQuery')

      // this.showSpinner = true;

      // const encodedCodeQuery = encodeURI(this.codeQuery)

      // // TODO: review event, perhaps deprecated

      // let query = ''
      // if (encodedCodeQuery.toLowerCase().includes('limit')) {
      //   query = encodedCodeQuery
      //   this.$root.$emit('hiddeShowButtonColumns')
      // } else {
      //   this.$root.$emit('ShowButtonColumns')
      //   this.$root.$emit('sendCompleteQuery', encodedCodeQuery)
      //   query = `SELECT%20*%20FROM%20(${encodedCodeQuery})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
      // }

      // this.$root.$emit('showMessages', false, true)

      // // factory method
      // this.getData({
      //   sql: query
      // })
      //   .then(response => {
      //     this.showSpinner = false;

      //     let data = []
      //     let keysData = []
      //     const rawData = response.data
      //     const meta = rawData.meta
      //     data = rawData.data

      //     const queryDurationRecords = [ meta.rows, meta.duration ]

      //     keysData = Object.keys(data[0])

      //     this.$root.$emit('recordsDuration', queryDurationRecords)
      //     this.$root.$emit('sendData', keysData, data)
      //     this.$root.$emit('postRecentQuery', this.codeQuery)
      //     this.$root.$emit('sendDataViz', data)
      //     this.$root.$emit('showMessages', true, false)
      //   })
      //   .catch(error => {
      //     const messageError = error.response.data.errors[0].sql
      //     this.$root.$emit('apiError', messageError)


      //     const data = []
      //     const keysData = []
      //     this.$root.$emit('sendData', keysData, data)

      //   })
    },
    recentQueries() {
      this.isActive = !this.isActive;
    },
    showRecentQueries() {
      if (this.isActive === true) {
        this.isActive = false
      } else {
        this.isActive = true;
        this.isHidden = true
      }
    },
    closeMenu() {
      this.isActive = false
    },
    closeQueriesModal() {
      this.isHidden = true
    },
    openYourQueries() {
      if (this.isHidden === false) {
        this.isHidden = true
      } else {
        this.isHidden = false
        this.isActive = false
      }
    },
    // TODO: sacar de aquí
    postQuery() {
      const endPoint = `${baseUrl}/queries`
      this.privacyStatus = this.privateQuery === false ? 'open' : 'closed'
      if (this.oldQueryName === this.labelQueryName && this.userId === this.userIdQuery) {
        const endPoint = `${baseUrl}/queries/${this.queryId}`
        let dataUpdate = {
            "data": {
                "type": "gobierto_data-queries",
                "attributes": {
                    "privacy_status": this.privacyStatus,
                    "sql": this.codeQuery
                }
            }
        }

        axios.put(endPoint, dataUpdate, {
          headers: {
            'Content-type': 'application/json',
            'Authorization': `${this.token}`
          }
        }).then(response => {
            this.resp = response;
            this.$root.$emit('reloadPrivateQueries')
            this.$root.$emit('reloadPublicQueries')
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        });
      } else {
        const endPoint = `${baseUrl}/queries`
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
        axios.post(endPoint, data, {
          headers: {
            'Content-type': 'application/json',
            'Authorization': `${this.token}`
          }
        }).then(response => {
            this.resp = response;
            this.$root.$emit('reloadPrivateQueries')
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        });
      }
    },
    runRecentQuery(code) {
      this.codeQuery = code
      this.runQuery()
    }
  }
}
</script>
