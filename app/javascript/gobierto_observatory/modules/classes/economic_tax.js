import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class EconomicTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        iae_coef_min as value
      FROM tasas
      WHERE
        place_id = ${city_id}
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/tasas/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        value: Number(jsonData.data[0].value),
        cardName: "economic_tax"
      };

      new SimpleCard(this.container, jsonData.data, opts);
    });
  }
}
