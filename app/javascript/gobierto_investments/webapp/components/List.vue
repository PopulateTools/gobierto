<template>
  <div v-if="items.length">
    <Table
      :data="itemsParsed"
      :columns="columns"
      :show-column-selector="false"
      :sort-column="sortColumn"
      :sort-direction="sortDirection"
      class="investments-home-main--table"
      @on-href-click="handleClick"
    >
      <template #pagination="{ paginator, data }">
        <ShowAll
          v-if="items.length > maxItems"
          :key="createHash(data)"
          :show="isAllVisible"
          @show-all="e => showAll(e, paginator, data)"
        />
      </template>
    </Table>
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import { Table } from '../../../lib/vue/components';
import ShowAll from './ShowAll.vue';
import { CommonsMixin } from '../mixins/common.js';

export default {
  name: "List",
  components: {
    Table,
    ShowAll
  },
  mixins: [CommonsMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      columns: [],
      sortColumn: null,
      sortDirection: null,
      labelEmpty: "",
      isAllVisible: false,
      maxItems: 24
    };
  },
  computed: {
    itemsParsed() {
      return this.items.map(({ id, availableTableFields }) => {
        // Requires the href to make it clickable
        const { href } = this.$router.resolve({ name: "project", params: { id } })
        // Keep just the need values
        const values = availableTableFields.reduce((acc, { id, value }) => ({ ...acc, [id]: value }), {})
       return { id, href, ...values }
      })
    },
  },
  created() {
    this.labelEmpty = I18n.t("gobierto_investments.projects.empty");

    const { availableTableFields = [] } = this.items.length
      ? this.items[0]
      : {};

    this.columns = availableTableFields.map(({ name, id, field_type: type, sort }) => ({ name, field: id, type, sort }));
    ({ field: this.sortColumn, sort: this.sortDirection } = this.columns.find(({ sort }) => !!sort ) || {})
  },
  methods: {
    showAll(isAllVisible, paginator, data) {
      this.isAllVisible = isAllVisible
      paginator(isAllVisible ? data : data.slice(0, this.maxItems))
    },
    handleClick({ id }) {
      // Since we adapted the original array to make it work the table component,
      // we need to get it back which object has been clicked from the original array
      const item = this.items.find(x => +x.id === +id)
      this.nav(item)
    },
    createHash(data) {
      // create a string-type key joining the top 20th element-ids
      // useful to reload the showall component when the table items order changes
      return data.slice(0, 20).reduce((acc, x) => `${acc}${x.id}`, '')
    }
  }
};
</script>
