import "../stylesheets/gobierto-visualizations.scss"

import { ContractsController } from "./modules/contracts_controller.js";
import { SubsidiesController } from "./modules/subsidies_controller.js";
import { CostsController } from "./modules/costs_controller.js";

document.addEventListener('DOMContentLoaded', () => {
  const contractsAppNode = document.getElementById("gobierto-visualizations-contracts-app");
  if (contractsAppNode) {
    new ContractsController({ ...contractsAppNode.dataset });
  }

  const subsidiesAppNode = document.getElementById("gobierto-visualizations-subsidies-app");
  if (subsidiesAppNode) {
    new SubsidiesController({ ...subsidiesAppNode.dataset });
  }

  const costsAppNode = document.getElementById("gobierto-visualizations-costs-app");
  if (costsAppNode) {
    new CostsController({ ...costsAppNode.dataset });
  }
});
