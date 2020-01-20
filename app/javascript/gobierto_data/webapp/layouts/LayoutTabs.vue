<template>
  <div>
    <Sidebar
      :active-tab="activeTabIndex"
      @active-tab="activeTabIndex = $event"
    >
      <template v-slot:sidebar>
        <slot name="sidebar" />
      </template>
    </Sidebar>
    <slot />
  </div>
</template>
<script>

import Sidebar from "./../components/Sidebar.vue";

export default {
  components: {
    Sidebar
  },
  data() {
    return {
      activeTabIndex: 0
    }
  }
}

</script>
