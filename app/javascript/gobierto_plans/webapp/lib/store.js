export const PlansStore = {
  state: {
    options: {},
    plainItems: [],
    meta: [],
    projects: [],
    status: [],
  },
  setOptions(keys) {
    this.state.options = keys || this.state.options
  },
  setPlainItems(items) {
    this.state.plainItems = items || this.state.plainItems
  },
  setMeta(meta) {
    this.state.meta = meta || this.state.meta
  },
  setProjects(projects) {
    this.state.projects = projects || this.state.projects
  },
  setStatus(status) {
    this.state.status = status || this.state.status
  }
}