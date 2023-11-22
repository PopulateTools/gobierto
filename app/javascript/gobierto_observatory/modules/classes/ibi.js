import { TableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class IbiCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      WITH
        maxyear AS (SELECT max(year) FROM tasas WHERE place_id = ${city_id}
                    AND (ibi_urbana IS NOT NULL OR ibi_rustica IS NOT NULL))
      SELECT
        1 as index,
        '${window.populateData.municipalityName}' as key,
        ibi_urbana as value_1,
        ibi_rustica as value_2,
        'first_column' as column
      FROM tasas
      WHERE
        place_id = ${city_id}
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        2 as index,
        '${window.populateData.provinceName}' as key,
        avg(ibi_urbana) as value_1,
        avg(ibi_rustica) as value_2,
        'second_column' as column
      FROM tasas
      WHERE
        place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
      AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        3 as index,
        '${I18n.t("country")}' as key,
        avg(ibi_urbana) as value_1,
        avg(ibi_rustica) as value_2,
        'third_column' as column
      FROM tasas
      WHERE
        year = (SELECT * FROM maxyear)
      ORDER BY index
      `;

    this.metadata = this.getMetadataEndpoint("tasas");
  }

  getData([jsonData, jsonMetadata]) {
    var opts = {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "ibi"
    };

    new TableCard(this.container, jsonData.data, opts);
  }
}
