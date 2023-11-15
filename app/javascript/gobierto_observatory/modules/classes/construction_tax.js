import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class ConstructionTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
    window.populateData.endpoint +
    `
    WITH
      maxyear AS (SELECT max(year) FROM tasas WHERE place_id = ${city_id})
    SELECT
      1 as index,
      icio as value
    FROM tasas
    WHERE
      place_id = ${city_id}
      AND year = (SELECT * FROM maxyear)
    UNION
    SELECT
      2 as index,
      avg(icio) as value
    FROM tasas
    WHERE
      year = (SELECT * FROM maxyear)
    ORDER BY 1
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
      var [placeTax, provinceTax] = jsonData.data;

      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "construction_tax"
      };

      new ComparisonCard(this.container, Number(placeTax.value), Number(provinceTax.value), opts);
    });
  }
}
