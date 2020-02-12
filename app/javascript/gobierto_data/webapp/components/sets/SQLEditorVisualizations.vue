<template>
  <div id="container">
    <perspective-viewer />
  </div>
</template>
<script>
import perspective from "@finos/perspective";
import viewer from "@finos/perspective-viewer";
import "@finos/perspective-viewer-hypergrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";

export default {
  name: 'SQLEditorVisualizations',
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      dataPerspective: [],
      viewer: '',
      initColumns: [],
      newColumns: []
    }
  },
  watch:{
    items: function(newValue){
      this.dataPerspective = JSON.parse(newValue);
    }
  },
  created(){
    this.$root.$on('sendDataViz', this.updateValues)
    this.$nextTick(() => {
      this.viewer = document.getElementsByTagName("perspective-viewer")[0];
      this.dataPerspective = this.items
      this.initPerspective(this.dataPerspective)
    })
  },
  methods: {
    updateValues(values) {
      this.newColumns = []
      this.newColumns = Object.keys(values[0])
      if (JSON.stringify(this.newColumns) === JSON.stringify(this.initColumns)) {
        this.viewer.setAttribute('columns', JSON.stringify(this.newColumns))
        this.updatePerspectiveData(values)
      } else {
        this.viewer.setAttribute('columns', JSON.stringify(this.newColumns))
        this.updatePerspectiveColumns(values)
      }
    },
    initPerspective(data){
      this.initColumns = Object.keys(data[0])
      var table = perspective.worker().table(data);
      this.viewer.load(table);
    },
    updatePerspectiveData(values) {
      this.viewer.clear()
      this.viewer.load(values);
    },
    updatePerspectiveColumns(values) {
      var table = perspective.worker().table(values);
      this.viewer.load(table);
      this.initColumns = this.newColumns
    }
  }
}
</script>
<style>
#container {
  background-color: #ccc;
  width: 100%;
  height: 100%;
  letter-spacing: 0;
}

perspective-viewer {
  overflow: hidden;
  width: 100%;
  height: 600px;
}
</style>
