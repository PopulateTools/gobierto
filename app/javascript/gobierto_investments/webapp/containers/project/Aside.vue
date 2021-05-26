<template>
  <aside class="investments-project-aside--gap">
    <div class="investments-project-aside--block">
      <span class="investments-project-aside--block-head">
        {{ project.phasesFieldName }}
      </span>

      <Steps
        :steps="phasesMutated"
      />
    </div>
  </aside>
</template>

<script>
import Steps from "../../components/Steps.vue";
import { CommonsMixin } from "../../mixins/common.js";

export default {
  name: "ProjectAside",
  components: {
    Steps
  },
  mixins: [CommonsMixin],
  props: {
    phases: {
      type: Array,
      default: () => []
    },
    project: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      phasesMutated: []
    }
  },
  created() {
    const { phases = [] } = this.project;
    const activePhases = phases.map(p => p.id);

    this.phasesMutated = this.phases.map(phase => ({ ...phase, active: activePhases.includes(phase.id) }))
  }
};
</script>

