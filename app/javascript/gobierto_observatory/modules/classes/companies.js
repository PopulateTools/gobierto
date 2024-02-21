import { SimpleCard } from "lib/visualizations";
import { Card } from "./card.js";

export class CompaniesCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        total_companies::integer AS value
      FROM dirce
      WHERE place_id = ${city_id}
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = this.getMetadataEndpoint("dirce");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "companies"
    };

    new SimpleCard(this.container, jsonData.data, opts);
  }
}
