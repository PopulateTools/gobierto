<template>
  <div class="investments-project-main--table-row">
    <div class="investments-project-main--cell-heading">
      {{ name }}
    </div>

    <!-- Table type -->

    <div
      v-if="type === 'table' && table && table.columns"
      class="investments-project-main--table-container"
    >
      <!-- Table header with column titles -->
      <div class="investments-project-main--inner-table-row investments-project-main--inner-table-header">
        <div
          v-for="column in table.columns"
          :key="`header-${column.id}`"
          class="investments-project-main--inner-table-cell"
        >
          <strong>{{ translate(column.name_translations) }}</strong>
        </div>
      </div>
      <!-- Table rows with data -->
      <div
        v-for="(v, i) in value"
        :key="`${v}-${i}`"
        class="investments-project-main--inner-table-row"
      >
        <div
          v-for="column in table.columns"
          :key="`${column.id}-${v}`"
          class="investments-project-main--inner-table-cell"
        >
          <div v-if="column.type === 'vocabulary'">
            {{ getVocabularyValue(column.id, v[column.id]) }}
          </div>
          <div v-else-if="column.type === 'date' || column.filter === 'date'">
            {{ v[column.id] | date }}
          </div>
          <div v-else-if="column.type === 'money' || column.filter === 'money'">
            {{ v[column.id] | money }}
          </div>
          <div v-else>
            {{ v[column.id] }}
          </div>
        </div>
      </div>
    </div>
    <div v-else-if="type === 'table' && (!table || !table.columns)">
      <em>{{ value || "Table configuration missing" }}</em>
    </div>

    <!-- Icon type -->
    <div v-else-if="type === 'icon'">
      <template v-for="(v, i) in value">
        <div
          :key="`${v}-${i}`"
          class="investments-project-main--icon-text"
        >
          <i :class="`fas fa-${icon.name}`" /> <a
            :href="v[icon.href]"
            target="_blank"
          >{{ v[icon.title] }}</a>
        </div>
      </template>
    </div>

    <!-- Highlight type -->
    <div v-else-if="type === 'highlight'">
      <strong class="investments-project-main--strong">{{ value }}</strong>
    </div>

    <!-- Link type -->
    <div v-else-if="type === 'link'">
      <a
        :href="value"
        target="_blank"
      >{{ value }}</a>
    </div>

    <!-- Simple type -->
    <div v-else>
      {{ value || "--" }}
    </div>
  </div>
</template>

<script>
import { CommonsMixin } from '../mixins/common.js';

export default {
  name: "DictionaryItem",
  mixins: [CommonsMixin],
  props: {
    name: {
      type: String,
      default: ""
    },
    value: {
      type: [String, Array, Number, Object],
      default: ""
    },
    type: {
      type: String,
      default: ""
    },
    icon: {
      type: Object,
      default: () => {}
    },
    table: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      vocabularyLookup: {}
    };
  },
  created() {
    if (this.type === 'table' && this.table && this.table.vocabulary_terms) {
      this.buildVocabularyLookup();
    }
  },
  methods: {
    buildVocabularyLookup() {
      // Build a lookup dictionary from vocabulary_terms
      // vocabulary_terms contains all terms for all vocabularies used in the table
      if (Array.isArray(this.table.vocabulary_terms)) {
        this.table.vocabulary_terms.forEach(term => {
          // Map term id to translated name
          this.vocabularyLookup[term.id] = this.translate(term.name_translations);
        });
      }
    },
    getVocabularyValue(columnId, value) {
      // Look up the term by its ID
      if (this.vocabularyLookup[value]) {
        return this.vocabularyLookup[value];
      }
      // Fallback to original value if not found
      return value || '-';
    }
  }
};
</script>
