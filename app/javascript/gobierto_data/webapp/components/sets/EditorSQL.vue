<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <div class="gobierto-data-sql-editor-toolbar">
        <Button
          class="btn-sql-editor"
          :text="undefined"
          icon="times"
          color="var(--color-base)"
          background="#fff"
        />
        <Button
          class="btn-sql-editor"
          :text="labelRecents"
          icon="history"
          color="var(--color-base)"
          background="#fff"
          :disabled="disabledRecents"
        />
        <Button
          class="btn-sql-editor"
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
            type="text"
            :placeholder="labelQueryName"
            class="gobierto-data-sql-editor-container-save-text"
          >
          <input
            :id="labelPrivate"
            type="checkbox"
            class="gobierto-data-sql-editor-container-save-checkbox"
            @change="marked = !marked"
          >
          <label
            class="gobierto-data-sql-editor-container-save-label"
            :for="labelPrivate"
          >
            {{ labelPrivate }}
          </label>
        </div>
        <Button
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
          v-if="saveQueryState"
          class="btn-sql-editor"
          :text="labelCancel"
          icon="undefined"
          color="var(--color-base)"
          background="#fff"
        />
        <Button
          class="btn-sql-editor"
          :text="labelRunQuery"
          icon="play"
          color="var(--color-base)"
          background="#fff"
          :disabled="disabledRunQuery"
          @click.native="execute()"
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
      `SELECT * FROM mobiliario_urbano`
    return {
      code,
      disabledRecents: true,
      disabledQueries: false,
      disabledSave: true,
      disabledRunQuery: true,
      saveQueryState: false,
      marked: false,
      labelSave: '',
      labelRecents: '',
      labelQueries: '',
      labelRunQuery: '',
      labelCancel: '',
      labelPrivate: '',
      labelQueryName: '',
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
  },
  methods: {
    onCmReady(cm) {

      cm.on('keypress', () => {
        this.disabledRecents = false
        this.disabledSave = false
        this.disabledRunQuery = false
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
    execute() {
      let oneLine = this.code.replace(/\n/g, ' ');
      oneLine = oneLine.replace(/  +/g, ' ');
      alert('Ejecutando consulta ' + oneLine)
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
      if (this.saveQueryState === true) {
        console.log('guardamos la consulta')
      }
      this.saveQueryState = true
    }
  }
}
</script>
