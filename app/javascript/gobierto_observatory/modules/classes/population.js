import { SimpleCard } from '../../../lib/visualizations';
import { Card } from './card.js';

export class PopulationCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      SELECT
        CONCAT(year, '-', 1, '-', 1) AS date,
        SUM(total::integer) AS value
      FROM poblacion_edad_sexo
      WHERE
        place_id = ${city_id}
        AND sex = 'Total'
      GROUP BY year
      ORDER BY 1 DESC
      LIMIT 5
      `;

    this.metadata = this.getMetadataEndpoint("poblacion-edad-sexo");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "population"
    };

    new SimpleCard(this.container, jsonData.data, opts);
  }
}
