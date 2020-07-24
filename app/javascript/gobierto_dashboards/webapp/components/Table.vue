<template>
  <div v-if="items.length">
    <table class="dashboards-home-main--table">
      <thead>
        <th
          v-for="{ field, translation, cssClass } in columns"
          :key="field"
          class="dashboards-home-main--th"
          :class="cssClass"
        >
          <div>{{ translation }}</div>
        </th>
      </thead>
      <TableRow
        v-for="item in displayedData"
        :key="item.id"
        :item="item"
        :routing-member="routingMember"
        :routing-attribute="routingAttribute"
        :columns="columns"
      />
      <nav
        class="gobierto-pagination"
      >
        <button
          class="gobierto-pagination-btn"
          :disabled="page === 1"
          @click="page--"
        >
          Previous
        </button>
        <ul class="gobierto-pagination-pages">
          <li
            class="gobierto-pagination-pages-element"
            v-for="pageNumber in paginationOptions"
            :key="pageNumber"
          >
            <button
              class="gobierto-pagination-pages-element-btn"
              :disabled="pageNumber === page"
              @click="page = pageNumber"
            >
              {{ pageNumber }}
            </button>
          </li>
        </ul>
        <button
          class="gobierto-pagination-btn"
          :disabled="page === pages.slice(-1)[0]"
          @click="page++"
        >
          Next
        </button>
      </nav>
    </table>
  </div>
  <div v-else>
    {{ labelEmpty }}
  </div>
</template>

<script>
import TableRow from "./TableRow.vue";

export default {
  name: "Table",
  components: {
    TableRow
  },
  props: {
    items: {
      type: Array,
      default: () => []
    },
    columns: {
      type: Array,
      default: () => []
    },
    routingMember: {
      type: String,
      default: ''
    },
    routingAttribute: {
      type: String,
      default: 'id'
    }
  },
  data() {
    return {
      labelEmpty: I18n.t("gobierto_dashboards.dashboards.contracts.empty_table"),
      perPage: 10,
      page: 1,
      pages: [],
    };
  },
  computed: {
    displayedData() {
      return this.paginateData(this.items);
    },
    paginationOptions() {
      let page = this.page;
      let len = this.pages.length;
      if (page - len >= -1 && len > 3) {
        return this.pages.slice(page - ((page - len) + (5 < len ? 5 : len)), len);
      } else {
        return this.pages.slice(page - (page < 4 ? page : 3), page + (5 - (page < 4 ? page : 3)));
      }
    }
  },
  watch:{
    perPage(value) {
      if (typeof value === 'string' && value.length < 3) {
        this.page = 1;
        this.setPages();
      }
    }
  },
  created() {
    this.setPages();
  },
  methods: {
    setPages() {
      this.pages.splice(0, this.pages.length);
      let pageCount = Math.ceil(this.items.length / this.perPage);
      for (let index = 1; index <= pageCount; index++) {
        this.pages.push(index);
      }
    },
    paginateData(data) {
      let page = this.page;
      let perPage = this.perPage;
      let from = (page * perPage) - perPage;
      let to = (page * perPage);
      return data.slice(from, to);
    }
  }
};
</script>
