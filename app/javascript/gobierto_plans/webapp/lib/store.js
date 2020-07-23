export const PlansStore = {
  state: {
    options: {},
    plainItems: [],
    meta: [],
    projects: [],
    status: [],
  },
  setOptions(keys) {
    this.state.options = keys
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