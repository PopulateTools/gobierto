import { GobiertoDataController } from "./modules/gobierto_data_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const appNode = document.getElementById("gobierto-data-app");

  new GobiertoDataController({
    siteName: appNode.dataset.siteName,
    logoUrl: appNode.dataset.logoUrl,
    homeUrl: appNode.dataset.homeUrl,
    tourUrl: appNode.dataset.tourUrl
  });
});
