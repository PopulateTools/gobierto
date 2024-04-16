import "../stylesheets/gobierto-visualizations.scss"

import { ContractsController } from "./modules/contracts_controller.js";
import { SubsidiesController } from "./modules/subsidies_controller.js";
import { CostsController } from "./modules/costs_controller.js";
import { DebtsController } from "./modules/debts_controller.js";
import { appsignal } from 'lib/shared'

appsignal.wrap(() => {
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

    const debtsAppNode = document.getElementById("gobierto-visualizations-debts-app");
    if (debtsAppNode) {
      new DebtsController({ ...debtsAppNode.dataset });
    }
  });
})
