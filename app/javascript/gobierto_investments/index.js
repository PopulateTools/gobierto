import "../stylesheets/gobierto-investments.scss"

import { InvestmentsController } from "./modules/investments_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const appNode = document.getElementById("investments-app");

  new InvestmentsController({
    siteName: appNode.dataset.siteName,
    logoUrl: appNode.dataset.logoUrl,
    homeUrl: appNode.dataset.homeUrl,
    tourUrl: appNode.dataset.tourUrl
  });
});
