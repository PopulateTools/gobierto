import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class CarsTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    // NOTE: the place_id consists of five numbers,
    // where the first two are the province code, so,
    // to get the province average we need to filter
    // for all the elements sharing that numbers.
    //
    // Example:
    // when, city_id = 15500
    // then the province, place_id BETWEEN 15000 AND 15999
    var lower = Math.trunc(parseInt(city_id) / 1e3) * 1e3
    var upper = Math.ceil(parseInt(city_id) / 1e3) * 1e3 - 1

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
        place_id BETWEEN ${lower} AND ${upper}
        AND year = (SELECT max(year) FROM tasas)
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
        value_1: Number(placeTax.value),
        value_2: Number(provinceTax.value),
        cardName: "cars_tax"
      };

      new ComparisonCard(this.container, jsonData.data, opts);
    });
  }
}
