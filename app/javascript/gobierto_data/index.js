import "../stylesheets/gobierto-data.scss"
import { GobiertoDataController } from "./modules/gobierto_data_controller.js";
import { appsignal } from 'lib/shared'

appsignal.wrap(() => {
  document.addEventListener('DOMContentLoaded', () => {
    const appNode = document.getElementById("gobierto-datos-app");

    if (appNode) {
      const { siteName, logoUrl, homeUrl, registrationDisabled } = appNode.dataset
      new GobiertoDataController({ siteName, logoUrl, homeUrl, registrationDisabled });
    }
  });
})
