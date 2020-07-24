<template>
  <nav class="gobierto-pagination">
    <button
      class="gobierto-pagination-btn"
      :disabled="page === 1"
      @click="page--"
    >
      Previous
    </button>
    <ul>
      <li
        v-for="pageNumber in paginationOptions"
        :key="pageNumber"
      >
        <button
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
</template>

<script>

export default {
  name: "Pagination",
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
