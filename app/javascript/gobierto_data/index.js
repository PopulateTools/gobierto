import { GobiertoDataController } from "./modules/gobierto_data_controller.js";
import "../../assets/stylesheets/comp-block-checkbox.scss"
import "../../assets/stylesheets/comp-block-header.scss"


document.addEventListener('DOMContentLoaded', () => {
  const appNode = document.getElementById("gobierto-datos-app");

  new GobiertoDataController({
    siteName: appNode.dataset.siteName,
    logoUrl: appNode.dataset.logoUrl,
    homeUrl: appNode.dataset.homeUrl,
    tourUrl: appNode.dataset.tourUrl
  });
});
