import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class BudgetByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-presupuestos-municipales-total.json?filter_by_kind=G&sort_desc_by=year&with_metadata=true&limit=5&filter_by_organization_id=" +
      city_id;
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(jsonData => {
      var value = jsonData.data[0].total_budget_per_inhabitant;

      jsonData.data.forEach(function(d) {
        d.date = `${d.year}-01-01`
        d.value = d.total_budget_per_inhabitant
      });

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
