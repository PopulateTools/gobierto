import "../../assets/stylesheets/module-dashboards.scss"

import { ContractsController } from "./modules/contracts_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const appNode = document.getElementById("gobierto-dashboards-contracts-app");

  new ContractsController({
    siteName: appNode.dataset.siteName,
    logoUrl: appNode.dataset.logoUrl,
    homeUrl: appNode.dataset.homeUrl,
    contractsEndpoint: appNode.dataset.contractsEndpoint,
    tendersEndpoint: appNode.dataset.tendersEndpoint,
    dataDownloadEndpoint: appNode.dataset.dataDownloadEndpoint,
  });
});
