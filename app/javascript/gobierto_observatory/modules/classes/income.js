import { TableCard } from '../../../lib/visualizations';
import { Card } from './card.js';

export class IncomeCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      WITH
        maxyear AS (SELECT max(year) FROM renta_habitante WHERE place_id = ${city_id}
                    AND (renta_media_hogar IS NOT NULL OR renta_media_habitante IS NOT NULL))
      SELECT
        1 as index,
        '${window.populateData.municipalityName}' as key,
        renta_media_habitante as value_1,
        renta_media_hogar as value_2,
        'first_column' as column
      FROM renta_habitante
      WHERE
        place_id = ${city_id}
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        2 as index,
        '${window.populateData.provinceName}' as key,
        avg(renta_media_habitante) as value_1,
        avg(renta_media_hogar) as value_2,
        'second_column' as column
      FROM renta_habitante
      WHERE
        place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
      AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        3 as index,
        '${I18n.t("country")}' as key,
        avg(renta_media_habitante) as value_1,
        avg(renta_media_hogar) as value_2,
        'third_column' as column
      FROM renta_habitante
      WHERE
        year = (SELECT * FROM maxyear)
      ORDER BY index
      `;

    this.metadata = this.getMetadataEndpoint("renta-habitante");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "income"
    };

    new TableCard(this.container, jsonData.data, opts);
  }
}
