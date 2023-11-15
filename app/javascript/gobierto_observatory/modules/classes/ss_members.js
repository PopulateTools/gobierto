import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class ssMembersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        year,
        SUM(value::integer) AS value,
        CONCAT(year, '-', 1, '-', 1) AS date
      FROM afiliados_seguridad_social
      WHERE
        place_id = ${city_id}
      GROUP BY year
      ORDER BY year DESC LIMIT 5
      `;
    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/afiliados-seguridad-social/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        value: jsonData.data[0].value,
        cardName: "ss_members"
      };

      new SimpleCard(this.container, jsonData.data, opts);
    });
  }
}
