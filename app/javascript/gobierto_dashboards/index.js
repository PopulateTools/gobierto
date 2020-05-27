import "../../assets/stylesheets/module-dashboards.scss"

import { ContractsController } from "./modules/contracts_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const contractsAppNode = document.getElementById("gobierto-dashboards-contracts-app");
  if (contractsAppNode) {
    new ContractsController({
      siteName: contractsAppNode.dataset.siteName,
      logoUrl: contractsAppNode.dataset.logoUrl,
      homeUrl: contractsAppNode.dataset.homeUrl,
      contractsEndpoint: contractsAppNode.dataset.contractsEndpoint,
      tendersEndpoint: contractsAppNode.dataset.tendersEndpoint,
      dataDownloadEndpoint: contractsAppNode.dataset.dataDownloadEndpoint,
    });
  }
});
