import "../../assets/stylesheets/module-data.scss"
import { GobiertoDataController } from "./modules/gobierto_data_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const appNode = document.getElementById("gobierto-datos-app");

  if (appNode) {
    const { siteName, logoUrl, homeUrl, tourUrl } = appNode.dataset
    new GobiertoDataController({ siteName, logoUrl, homeUrl, tourUrl });
  }
});
