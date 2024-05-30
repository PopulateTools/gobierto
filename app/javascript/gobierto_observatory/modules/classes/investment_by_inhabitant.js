import { Sparkline, SparklineTableCard } from '../../../lib/visualizations';
import { groupBy } from '../../../lib/shared';
import { Card } from './card.js';

export class InvestmentByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      (
        SELECT
          1 as index,
          '${window.populateData.municipalityName}' as key,
          CONCAT(year, '-', 1, '-', 1) AS date,
          SUM(amount_per_inhabitant::decimal) as value
        FROM presupuestos_municipales
        WHERE
          place_id = ${city_id}
        AND area = 'e' and kind = 'G' and code IN ('6','7')
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      UNION
      (
        SELECT
          2 as index,
          '${window.populateData.provinceName}' as key,
          CONCAT(year, '-', 1, '-', 1) AS date,
          AVG(amount_per_inhabitant::decimal) as value
        FROM presupuestos_municipales
        WHERE
          place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
        AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
        AND area = 'e' and kind = 'G' and code IN ('6','7')
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      UNION
      (
        SELECT
          3 as index,
          '${I18n.t("country")}' as key,
          CONCAT(year, '-', 1, '-', 1) AS date,
          AVG(amount_per_inhabitant::decimal) as value
        FROM presupuestos_municipales
        WHERE
          area = 'e' and kind = 'G' and code IN ('6','7')
        GROUP BY year
        ORDER BY year DESC
        LIMIT 5
      )
      ORDER BY index
      `;

    this.metadata = this.getMetadataEndpoint("presupuestos-municipales");
  }

  getData([jsonData, jsonMetadata]) {
    const locations = groupBy(jsonData.data, "key");

    // transform the data for the chart
    const nestData = Object.entries(locations).map(([key, values]) => ({
      key: this._normalize(key),
      value: values[0].value,
      diff: values[1].value ? (values[0].value / values[1].value - 1) * 100 : 100,
      title: key
    }));

    new SparklineTableCard(this.container, nestData, {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "investment_by_inhabitant"
    });

    Object.entries(locations).forEach(([key, values]) => {
      const sorted = values.sort((a, b) => (a.date < b.date ? 1 : -1));

      const spark = new Sparkline(
        `${this.container} .sparkline-${this._normalize(key)}`,
        sorted,
        {
          trend: this.trend,
          freq: this.freq
        }
      );

      spark.render();
    });
  }
}
