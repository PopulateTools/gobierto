import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class EconomicTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        iae_coef_min::decimal AS value
      FROM tasas
      WHERE
        place_id = ${city_id}
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = this.getMetadataEndpoint("tasas");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "economic_tax"
    };

    new SimpleCard(this.container, jsonData.data, opts);
  }
}
