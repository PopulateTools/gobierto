import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields, getMetadataEndpoint } from "../helpers.js";

export class BudgetByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        SUM(amount_per_inhabitant::decimal) as value
      FROM presupuestos_municipales
      WHERE
        place_id = ${city_id}
      AND area = 'e' and kind = 'G' and length(code) = 1
      GROUP BY year
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = getMetadataEndpoint("presupuestos-municipales")
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "budget_by_inhabitant"
      };

      new SimpleCard(this.container, jsonData.data, opts);
    });
  }
}
