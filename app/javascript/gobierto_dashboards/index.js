import { GobiertoEvents } from "lib/shared"
import { GobiertoDashboardMakerController } from "./modules/dashboard_maker_controller.js";
import { GobiertoDashboardViewerController } from "./modules/dashboard_viewer_controller.js";

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
document.addEventListener(GobiertoEvents.CREATE_DASHBOARD_EVENT, () => create(makerSelector, GobiertoDashboardMakerController))
document.addEventListener(GobiertoEvents.LOAD_DASHBOARD_EVENT, () => create(dashboardSelector, GobiertoDashboardViewerController))