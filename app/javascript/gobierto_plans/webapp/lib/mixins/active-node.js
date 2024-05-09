import { findRecursive } from '../helpers';

export const ActiveNodeMixin = {
  data() {
    return {
      activeNode: {},
      rootid: 0
    }
  },
  watch: {
    $route(to) {
      const {
        params: { id }
      } = to;
      this.setActiveNode(id);
    }
  },
  computed: {
    color() {
      return (this.rootid % this.json.length) + 1;
    }
  },
  created() {
    const {
      params: { id }
    } = this.$route;
    this.setActiveNode(id);
  },
  methods: {
    setActiveNode(id) {
      this.activeNode = findRecursive(this.json, id);

      if (this.activeNode) {
        const { rootid } = this.activeNode;

        // to determine the colors
        this.rootid = rootid
      }
    },
  }
}
