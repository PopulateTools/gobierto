import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ssMembersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      SELECT
        CONCAT(year, '-', month, '-', 1) AS date,
        SUM(value::integer) AS value
      FROM afiliados_seguridad_social
      WHERE
        place_id = ${city_id}
      GROUP BY year, month
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = this.getMetadataEndpoint("afiliados-seguridad-social");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "ss_members"
    };

    new SimpleCard(this.container, jsonData.data, opts);
  }
}
