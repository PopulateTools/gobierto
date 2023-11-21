import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class CarsTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT cars_taxes::integer as value
      FROM tasas
      WHERE
        place_id = ${city_id}
        AND year = (SELECT max(year) FROM tasas)
      UNION
      SELECT avg(cars_taxes ::integer) as value
      FROM tasas
      WHERE
        place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
        AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
        AND year = (SELECT max(year) FROM tasas)
      `;

    this.metadata = this.getMetadataEndpoint("tasas");
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var [placeTax, provinceTax] = jsonData.data;

      var opts = {
        metadata: this.getMetadataFields(jsonMetadata),
        cardName: "cars_tax"
      };

      new ComparisonCard(
        this.container,
        placeTax.value,
        provinceTax.value,
        opts
      );
    });
  }
}
