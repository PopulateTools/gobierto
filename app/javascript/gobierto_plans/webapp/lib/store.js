export const PlansStore = {
  state: {
    levelKeys: {},
    plainItems: []
  },
  setLevelKeys(keys) {
    this.state.levelKeys = keys
  },
  setPlainItems(items) {
    this.state.plainItems = items
  }
}