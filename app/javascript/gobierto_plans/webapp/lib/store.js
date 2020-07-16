export const PlansStore = {
  state: {
    levelKeys: {},
    plainItems: [],
    meta: [],
    status: [],
  },
  setLevelKeys(keys) {
    this.state.levelKeys = keys
  },
  setPlainItems(items) {
    this.state.plainItems = items
  },
  setMeta(meta) {
    this.state.meta = meta
  },
  setStatus(status) {
    this.state.status = status
  }
}