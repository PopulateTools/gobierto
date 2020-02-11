<template>
  <div id="container">
    <perspective-viewer editable />
  </div>
</template>
<script>
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
      dataPerspective: []
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
      this.dataPerspective = this.items
      this.initPerspective(this.dataPerspective)
    })
  },
  methods: {
    updateValues(values) {
      this.initPerspective(values)
    },
    initPerspective(data){
      const viewer = document.getElementsByTagName("perspective-viewer")[0];
      viewer.load(data);
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
