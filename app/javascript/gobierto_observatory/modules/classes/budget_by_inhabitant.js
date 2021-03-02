import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class BudgetByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-presupuestos-municipales-total.json?sort_desc_by=year&with_metadata=true&limit=5&filter_by_organization_id=" +
      city_id;
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(jsonData => {
      var value = jsonData.data[0].total_budget_per_inhabitant;

      new SimpleCard(
        this.container,
        jsonData,
        value,
        "budget_by_inhabitant",
        "total_budget_per_inhabitant"
      );
    });
  }
}
