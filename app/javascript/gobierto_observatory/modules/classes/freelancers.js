import { SimpleCard } from '../../../lib/visualizations';
import { Card } from './card.js';

export class FreelancersCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
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

    this.metadata = this.getMetadataEndpoint("afiliados-seguridad-social");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "freelancers"
    };

    new SimpleCard(this.container, jsonData.data, opts);
  }
}
