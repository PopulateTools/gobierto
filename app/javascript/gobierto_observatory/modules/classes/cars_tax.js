import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields, getProvinceIds } from "../helpers.js";

export class CarsTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    const [lower, upper] = getProvinceIds(city_id);

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
        cardName: "cars_tax"
      };

      new ComparisonCard(this.container, Number(placeTax.value), Number(provinceTax.value), opts);
    });
  }
}
