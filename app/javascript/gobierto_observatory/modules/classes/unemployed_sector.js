import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { groupBy } from "lib/shared";
import { Card } from "./card.js";

export class UnemplBySectorCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.query = `
      SELECT
        value,
        CONCAT(year, '-', month, '-', 1) AS date,
        sector as key
      FROM paro_sectores
      WHERE
        place_id = ${city_id}
      ORDER BY year DESC, month DESC
      LIMIT 50
      `;

    this.metadata = this.getMetadataEndpoint("paro-sectores");
  }

  getData([jsonData, jsonMetadata]) {
    const sectors = groupBy(jsonData.data, "key");

    // transform the data for the chart
    const nestData = Object.entries(sectors).map(([key, values]) => ({
      key,
      value: values[0].value,
      diff: (values[0].value / values[1].value - 1) * 100,
      title: I18n.t(
        `gobierto_common.visualizations.cards.unemployed_sector.${key}`
      )
    }));

    new SparklineTableCard(this.container, nestData, {
      metadata: this.getMetadataFields(jsonMetadata),
      cardName: "unemployed_sector"
    });

    Object.entries(sectors).forEach(([key, values]) => {
      const sorted = values.sort((a, b) =>
        new Date(a.date) < new Date(b.date) ? 1 : -1
      );

      const spark = new Sparkline(
        `${this.container} .sparkline-${key}`,
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
