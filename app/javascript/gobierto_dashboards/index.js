import { GOBIERTO_DASHBOARDS } from '../lib/events'
import { GobiertoDashboardMakerController } from './modules/dashboard_maker_controller.js';
import { GobiertoDashboardViewerController } from './modules/dashboard_viewer_controller.js';

// use directives in order to create multiple elements
const makerSelector = "[dashboard-maker-app]"
const dashboardSelector = "[dashboard-viewer-app]"

// factory pattern
const create = (selector, Instance) => {
  const nodes = document.querySelectorAll(selector);

  if (nodes.length && typeof Instance === "function") {
    nodes.forEach(node => new Instance({ ...node.dataset, selector }).mount());
  }
}

// create elements onload
document.addEventListener("DOMContentLoaded", () => {
  create(makerSelector, GobiertoDashboardMakerController)
  create(dashboardSelector, GobiertoDashboardViewerController)
});

// create elements on custom-events
document.addEventListener(GOBIERTO_DASHBOARDS.CREATE, () => create(makerSelector, GobiertoDashboardMakerController))
document.addEventListener(GOBIERTO_DASHBOARDS.LOAD, () => create(dashboardSelector, GobiertoDashboardViewerController))
