export const translate = (value = {}) => {
  const lang = I18n.locale || "es";
  // Look for the language key, fallback to the first found key
  return Object.prototype.hasOwnProperty.call(value, lang) && value[lang]
    ? value[lang]
    : value[Object.keys(value)[0]];
};

export const money = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  const options = { style: "currency", currency: "EUR", ...opts };
  return value !== undefined && value !== null
    ? parseFloat(value).toLocaleString(lang, options)
    : undefined;
};

export const date = (value, opts = {}) => {
  const lang = I18n.locale || "es";
  return value instanceof Date
    ? value.toLocaleDateString(lang, opts)
    : new Date(value).toLocaleDateString(lang, opts);
};

export const truncate = (value, opts = {}) => {
  const length = opts["length"] || 30;
  const str = `${value || ""}`;

  if (str.length <= length) {
    return str;
  } else {
    const omission = opts["omission"] || "...";
    return `${str.substring(0, length)}${omission}`;
  }
};

export const percent = value => {
  if (typeof value !== "number") return;
  return (value / 100).toLocaleString(I18n.locale, {
    style: "percent",
    maximumFractionDigits: 1
  });
};

export const VueFiltersMixin = {
  methods: {
    translate,
    money,
    date,
    truncate,
    percent
  },
  filters: {
    translate,
    money,
    date,
    truncate,
    percent
  }
};

export const TableHeaderMixin = {
  defaults: {
    sortColumn: "id",
    sortDirection: "up",
  },
  data() {
    return {
      map: new Map(),
      currentSortColumn: this.$options.defaults.sortColumn,
      currentSort: this.$options.defaults.sortDirection
    };
  },
  computed: {
    tmpRows() {
      return this.data || []
    },
    rowsSorted() {
      const id = this.currentSortColumn;
      const sort = this.currentSort;
      return this.tmpRows
        .slice()
        .sort(({ [id]: termA }, { [id]: termB }) =>
          sort === "up"
            ? Number.isNaN(+termA)
              ? termA.localeCompare(termB)
              : +termA > +termB
              ? -1
              : 1
            : Number.isNaN(+termA)
            ? termB.localeCompare(termA)
            : +termA < +termB
            ? -1
            : 1
        );
    },
  },
  methods: {
    handleTableHeaderClick(id) {
      const { sort } = this.map.get(id);
      this.currentSortColumn = sort !== "down" ? id : this.$options.defaults.sortColumn;
      // toggle sort order: up -> down -> undefined
      const sortDirection = typeof sort === "undefined" ? "up" : sort === "up" ? "down" : undefined;
      this.currentSort = sortDirection ? sortDirection : this.$options.defaults.sortDirection
      // update the order for the item clicked
      this.map.set(id, { ...this.map.get(id), sort: sortDirection });
    },
    getSorting(column) {
      // ignore the first item of the tuple
      const { sort } = this.map.get(column)
      return sort;
    },
  }
};
