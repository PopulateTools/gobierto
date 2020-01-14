<template>
  <div>
    <div class="gobierto-data-sql-editor">
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
          background="#fff"
          :disabled="disabledQueries"
        />
        <div
          v-if="saveQueryState"
          class="gobierto-data-sql-editor-container-save"
        >
          <input
            ref="inputText"
            type="text"
            :placeholder="labelQueryName"
            :class="saveQueryState ? 'query-saved' : ''"
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
      <div class="codemirror">
        <codemirror
          ref="myCm"
          v-model="code"
          :options="cmOption"
          @ready="onCmReady"
          @input="onCmCodeChange"
          @blur="formatCode"
        />
      </div>
      <div class="gobierto-data-sql-editor-footer">
        <span class="gobierto-data-sql-editor-footer-records">
          {{ numberRecords }} registros
        </span>
        <span class="gobierto-data-sql-editor-footer-time">
          consulta ejecutada en {{ timeQuery }}s
        </span>
        <a
          href=""
          class="gobierto-data-sql-editor-footer-guide"
        >
          {{ labelGuide }}
        </a>
      </div>
    </div>
  </div>
</template>
<script>
import Button from "./../commons/Button.vue";
import sqlFormatter from "sql-formatter"
import 'codemirror/mode/sql/sql.js'
import 'codemirror/addon/selection/active-line.js'
import 'codemirror/addon/hint/show-hint.css'
import 'codemirror/addon/hint/show-hint.js'
import 'codemirror/addon/hint/sql-hint.js'
import { commands } from 'codemirror/src/edit/commands.js'
import 'codemirror/src/model/selection_updates.js'

export default {
  name: 'CodeMirror',
  components: {
    Button
  },
  data() {
        const code =
          `SELECT
      COUNT(*) AS lines,
      COUNT(*) FILTER (
        WHERE
          TO_NUMBER(t.quantity, '999999999999') > 0
          AND TO_NUMBER(t.value, '999999999999') > 0
      ) AS loadable_lines,
      COUNT(*) FILTER (
        WHERE
          t.type != 'import'
          AND t.type != 'export'
      ) AS invalid_type,
      STRING_AGG(m_commodity.hs_code, '^') AS missing_hs_codes,
      STRING_AGG(m_country.country, '^') AS missing_countries,
      STRING_AGG(m_unit.unit, '^') AS missing_units
    FROM
      staging_temp AS t
      LEFT JOIN m_commodity ON (m_commodity.id = t.id)
      LEFT JOIN m_country ON (m_country.id = t.id)
      LEFT JOIN m_unit ON (m_unit.id = t.id)`
    return {
      code,
      disabledRecents: true,
      disabledQueries: false,
      disabledSave: true,
      disabledRunQuery: true,
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
      labelGuide: '',
      nameQuery: '',
      numberRecords: '1337',
      timeQuery: '0.1',
      cmOption: {
        tabSize: 2,
        styleActiveLine: false,
        lineNumbers: false,
        styleSelectedText: false,
        line: true,
        foldGutter: true,
        mode: 'text/x-sql',
        hintOptions: {
          completeSingle: false,
          tables: {}
        },
        showCursorWhenSelecting: true,
        theme: "default",
        autoIndent: true,
        extraKeys: {
          "Ctrl": "autocomplete"
        }
      }
    }
  },
  computed: {
    codemirror() {
      return this.$refs.myCm.codemirror
    }
  },
  mounted() {
    this.cm = this.$refs.myCm.codemirror
    this.commands = commands
    const tables = {
      "table_1": [],
      "table_2": [],
      "table_3": [],
      "table_4": [],
      "table_5": [],
      "table_6": []
    }

    window.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.keyCode == 32) {
        this.formatCode()
        this.cm.setCursor(this.cm.lineCount(), 0);
      }
    });

    this.cmOption.hintOptions.tables = tables
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
  },
  methods: {
    onCmReady(cm) {

      cm.on('keypress', () => {
        this.disabledRecents = false
        this.disabledSave = false
        this.disabledRunQuery = false
        if (this.saveQueryState === true) {
          this.showLabelModified = true
          this.showBtnEdit = false
          this.showBtnSave = true
        }
        /*var options = {
          hint: function() {
            return {
              from: cm.getDoc().getCursor(),
              to: cm.getDoc().getCursor()
            }
          }
        }
        cm.showHint(options);*/
      })
    },
    formatCode() {
      this.commands.selectAll(this.cm)
      const formaterCode = sqlFormatter.format(this.code)
      this.cm.setValue(formaterCode)
    },
    runQuery() {
      let oneLine = this.code.replace(/\n/g, ' ');
      oneLine = oneLine.replace(/  +/g, ' ');
      alert('Run Query ' + oneLine)
    },
    onCmCodeChange(newCode) {
      this.code = newCode
    },
    saveCode() {
      const saveQuery = this.code
      this.arrayQuerys.push(saveQuery)
    },
    queryRandom() {
      this.commands.selectAll(this.cm)
      this.cm.setValue(this.arrayQuerys[0])
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
      } else {
        this.saveQueryState = true
        this.showBtnCancel = true
        this.setFocus()
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
    },
    cancelQuery() {
      this.showBtnCancel = false
      this.showBtnEdit = false
      this.showBtnSave = true
      this.showBtnRemove = true
      this.showLabelPrivate = false
      this.removeLabelBtn = false
      this.saveQueryState = false
    }
  }
}
</script>
