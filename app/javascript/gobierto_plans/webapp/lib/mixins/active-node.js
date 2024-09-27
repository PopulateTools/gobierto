import { findRecursive } from '../helpers';
import { NamesMixin } from './names';

export const ActiveNodeMixin = {
  data() {
    return {
      activeNode: {},
      rootid: 0
    }
  },
  mixins: [NamesMixin],
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

        // NOTE: since "status" field does not come from the API,
        // we fake it as a custom_field, copying the value of the identificator
        // see more: https://github.com/PopulateTools/issues/issues/2005
        if (Object.hasOwn(this.activeNode.attributes, "status_id")) {
          this.activeNode.attributes.status = this.activeNode.attributes.status_id.toString()
        }
      }
    },
  }
}
