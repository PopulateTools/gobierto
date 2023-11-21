import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields, getMetadataEndpoint } from "../helpers.js";

export class FreelancersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        SUM(value::integer) AS value
      FROM afiliados_seguridad_social
      WHERE
        place_id = ${city_id} AND
        type = 'R.E.TRABAJADORES CTA. PROP. O AUTONOMOS'
      GROUP BY year
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = getMetadataEndpoint("afiliados-seguridad-social")
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "freelancers"
      };

      new SimpleCard(this.container, jsonData.data, opts);
    });
  }
}
