// import "../../assets/stylesheets/module-TEMP.scss";
import { GobiertoDashboardMakerController } from "./modules/dashboard_maker_controller.js";
import { GobiertoDashboardViewerController } from "./modules/dashboard_viewer_controller.js";

const makerSelector = "#dashboard-maker-app"
const dashboardSelector = "#dashboard-viewer-app"
const create = (selector, Instance) => {
  const node = document.querySelector(selector);

  if (node && typeof Instance === "function") {
    new Instance({ ...node.dataset, selector }).mount();
  }
}

// create elements onload
document.addEventListener('DOMContentLoaded', () => {
  create(makerSelector, GobiertoDashboardMakerController)
  create(dashboardSelector, GobiertoDashboardViewerController)
});

// create elements on custom-events
document.addEventListener('create-dashboard-maker', () => create(makerSelector, GobiertoDashboardMakerController))