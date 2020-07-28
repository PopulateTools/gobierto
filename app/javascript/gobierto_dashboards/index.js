import "../../assets/stylesheets/module-dashboards.scss"

import { ContractsController } from "./modules/contracts_controller.js";
import { SubsidiesController } from "./modules/subsidies_controller.js";
import { CostsController } from "./modules/costs_controller.js";

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

  const subsidiesAppNode = document.getElementById("gobierto-dashboards-subsidies-app");
  if (subsidiesAppNode) {
    new SubsidiesController({
      siteName: subsidiesAppNode.dataset.siteName,
      logoUrl: subsidiesAppNode.dataset.logoUrl,
      homeUrl: subsidiesAppNode.dataset.homeUrl,
      subsidiesEndpoint: subsidiesAppNode.dataset.subsidiesEndpoint,
      dataDownloadEndpoint: subsidiesAppNode.dataset.dataDownloadEndpoint,
    });
  }

  const costsAppNode = document.getElementById("gobierto-dashboards-costs-app");
  if (costsAppNode) {
    new CostsController({
      siteName: costsAppNode.dataset.siteName,
      logoUrl: costsAppNode.dataset.logoUrl,
      homeUrl: costsAppNode.dataset.homeUrl,
      costsEndpoint: costsAppNode.dataset.costsEndpoint
    });
  }
});
