export const PlansStore = {
  state: {
    levelKeys: {},
    plainItems: [],
    meta: [],
    projects: [],
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
  setProjects(projects) {
    this.state.projects = projects
  },
  setStatus(status) {
    this.state.status = status
  }
}