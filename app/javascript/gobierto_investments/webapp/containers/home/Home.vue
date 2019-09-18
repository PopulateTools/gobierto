<template>
  <div>
    <div class="pure-g m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4" />
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav @active-tab="activeTabIndex = $event" />
      </div>
    </div>

    <div class="pure-g m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside :filters="filters" />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main
          :active-tab="activeTabIndex"
          :items="items"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";
import Nav from "./Nav.vue";
import axios from "axios";
import { CommonsMixin } from "../../mixins/common.js";

export default {
  name: "Home",
  components: {
    Aside,
    Main,
    Nav
  },
  mixins: [CommonsMixin],
  data() {
    return {
      items: [],
      dictionary: [],
      filters: [],
      activeTabIndex: 0
    };
  },
  created() {
    axios
      .all([
        axios.get(this.$baseUrl),
        axios.get(`${this.$baseUrl}/meta?stats=true`)
      ])
      .then(responses => {
        const [
          {
            data: { data: items = [] }
          },
          {
            data: {
              data: attributesDictionary = [],
              meta: filtersSelected = {}
            }
          }
        ] = responses;

        this.dictionary = attributesDictionary;
        this.items = this.parseData(items);

        for (const key in filtersSelected) {
          if (Object.prototype.hasOwnProperty.call(filtersSelected, key)) {
            const { field_type: type = "", vocabulary_terms: options = [], name_translations: title = {} } = this.getAttributesByKey(key);
            const element = filtersSelected[key];

            this.filters.push({
              ...element,
              title,
              options,
              type,
              key
            });
          }
        }
      });
  },
};
</script>