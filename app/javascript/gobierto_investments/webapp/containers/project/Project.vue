<template>
  <div>
    <h4 class="investments-project--heading">
      Detalle de proyecto
    </h4>
    <div class="pure-g">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside
          v-if="project"
          :items="project.phases"
        />
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main
          v-if="project"
          :project="project"
        />
      </div>
    </div>
  </div>
</template>

<script>
import Aside from "./Aside.vue";
import Main from "./Main.vue";
import axios from "axios";
import { CommonsMixin } from "../../mixins/common.js";

// IE polyfill. FIXME: delete this when babel don't use @babel-polyfill anymore
require('es6-promise').polyfill();

export default {
  name: "Project",
  components: {
    Aside,
    Main
  },
  mixins: [CommonsMixin],
  data() {
    return {
      dictionary: [],
      project: null
    };
  },
  created() {
    const { item } = this.$route.params;

    if (item) {
      this.project = item;
    } else {
      axios.all([axios.get(`${this.$baseUrl}/${this.$route.params.id}`), axios.get(`${this.$baseUrl}/meta?stats=true`)]).then(responses => {
        const [
          {
            data: { data: item }
          },
          {
            data: { data: attributesDictionary }
          }
        ] = responses;

        this.dictionary = attributesDictionary;
        this.project = this.setItem(item);
      });
    }
  }
};
</script>
