import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { groupBy } from "lib/shared";
import { Card } from "./card.js";
import { getMetadataFields, getProvinceIds, getMetadataEndpoint } from "../helpers.js";

export class InvestmentByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    const [lower, upper] = getProvinceIds(city_id);

    this.url =
      window.populateData.endpoint +
      `
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
          place_id between ${lower} and ${upper}
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

    this.metadata = getMetadataEndpoint("presupuestos-municipales")
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      const locations = groupBy(jsonData.data, "key");

      // transform the data for the chart
      const nestData = Object.entries(locations).map(([key, values]) => ({
        key: this._normalize(key),
        value: values[0].value,
        diff: (values[0].value / values[1].value - 1) * 100,
        title: key
      }));

      new SparklineTableCard(this.container, nestData, {
        metadata: getMetadataFields(jsonMetadata),
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
    });
  }
}
