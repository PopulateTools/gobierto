<template>
  <main class="gobierto-dashboards">
    <div class="pure-g gutters m_b_1">
      <Header />
      <Distribution
        v-if="costData"
        :data="costData"
      />
      <Detail
        :items="groupData"
        :data="costData"
      />
    </div>
  </main>
</template>

<script>
import Header from './Header.vue'
import Distribution from './Distribution.vue'
import Detail from './Detail.vue'
export default {
  name: 'Home',
  components: {
    Header,
    Distribution,
    Detail
  },
  data() {
    return {
      costData: this.$root.$data.costData,
      groupData: this.$root.$data.agrupacioData,
    }
  }
}
</script>
