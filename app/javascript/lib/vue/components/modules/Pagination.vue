<template>
  <nav
    v-if="showPagination"
    class="gobierto-pagination"
  >
    <button
      class="gobierto-pagination-btn"
      :disabled="disabledPrevButton"
      @click="prevPage"
    >
      {{ labelPrev }}
    </button>
    <ul class="gobierto-pagination-pages">
      <li
        v-for="pageNumber in paginationOptions"
        :key="pageNumber"
        class="gobierto-pagination-pages-element"
      >
        <button
          class="gobierto-pagination-pages-element-btn"
          :disabled="pageNumber === page"
          @click="currentPage(pageNumber)"
        >
          {{ pageNumber }}
        </button>
      </li>
    </ul>
    <button
      class="gobierto-pagination-btn"
      :disabled="disabledNextButton"
      @click="nextPage"
    >
      {{ labelNext }}
    </button>
  </nav>
</template>

<script>
export default {
  name: "Pagination",
  props: {
    data: {
      type: Array,
      default: () => []
    },
    itemsPerPage: {
      type: Number,
      default: 1
    },
    containerPagination: {
      type: String,
      default: ''
    },
  },
  data() {
    return {
      labelNext: I18n.t("gobierto_common.vue_components.pagination.next"),
      labelPrev: I18n.t("gobierto_common.vue_components.pagination.previous"),
      page: 1,
      pages: [],
    };
  },
  computed: {
    displayedData() {
      return this.paginateData(this.data);
    },
    paginationOptions() {
      let page = this.page;
      let len = this.pages.length;
      if (page - len >= -1 && len > 3) {
        return this.pages.slice(page - ((page - len) + (5 < len ? 5 : len)), len);
      } else {
        return this.pages.slice(page - (page < 4 ? page : 3), page + (5 - (page < 4 ? page : 3)));
      }
    },
    disabledPrevButton() {
      return this.page === 1
    },
    disabledNextButton() {
      //Disable the Next button when the current page is the last.
      return this.page === this.pages.slice(-1)[0]
    },
    showPagination() {
      return this.data.length > this.itemsPerPage
    }
  },
  watch:{
    perPage(value) {
      if (typeof value === 'string' && value.length < 3) {
        this.page = 1;
        this.setPages();
      }
    },
    page(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.paginateData(this.data);
      }
    },
    data(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.page = 1;
        this.setPages();
        this.paginateData(newValue);
      }
    }
  },
  created() {
    this.setPages();
    this.paginateData(this.data);
  },
  methods: {
    setPages() {
      this.pages.splice(0, this.pages.length);
      let pageCount = Math.ceil(this.data.length / this.itemsPerPage);
      for (let index = 1; index <= pageCount; index++) {
        this.pages.push(index);
      }
    },
    paginateData(data) {
      let page = this.page;
      let perPage = this.itemsPerPage;
      let from = (page * perPage) - perPage;
      let to = (page * perPage);
      const displayedData = data.slice(from, to);
      this.$emit('show-data', displayedData)
    },
    nextPage() {
      this.page++
      this.scrollToTop()
    },
    currentPage(pageNumber) {
      this.page = pageNumber
      this.scrollToTop()
    },
    prevPage() {
      this.page--
      this.scrollToTop()
    },
    scrollToTop() {
      const element = document.querySelector(this.containerPagination);
      element.scrollIntoView({ behavior: "smooth" });
    }
  }
};
</script>
