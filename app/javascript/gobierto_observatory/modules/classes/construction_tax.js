import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ConstructionTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
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

    this.metadata = this.getMetadataEndpoint("tasas");
  }

  getData([jsonData, jsonMetadata]) {
    var [placeTax, provinceTax] = jsonData.data;

    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "construction_tax"
    };

    new ComparisonCard(this.container, placeTax.value, provinceTax.value, opts);
  }
}
