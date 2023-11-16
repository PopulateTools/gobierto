import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { getMetadataFields, groupBy } from "../helpers";
import { Card } from "./card.js";

export class ContractsBySectorCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT
        value,
        CONCAT(year, '-', month, '-', 1) AS date,
        sector
      FROM contratos_sectores
      WHERE
        place_id = ${city_id}
      ORDER BY year DESC, month DESC
      LIMIT 50
      `;
    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/contratos-sectores/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      // d3v5
      //
      const nestData = nest()
        .key(d => d.sector)
        .rollup(v => ({
          value: v[0].value,
          diff: ((v[0].value - v[1].value) / v[1].value) * 100
        }))
        .entries(jsonData.data)
        .map(d => ({
          ...d,
          title: I18n.t(
            "gobierto_common.visualizations.cards.contracts_sector." + d.key
          ),
          diff: d.value.diff,
          value: d.value.value
        }));

      // d3v6
      //
      // nestData = rollup(
      //   jsonData.data,
      //   v => ({
      //     value: v[0].value,
      //     diff: ((v[0].value - v[1].value) / v[1].value) * 100
      //   }),
      //   d => d.sector
      // );

      // // Convert map to specific array
      // nestData = Array.from(nestData, ([key, { value, diff }]) => ({
      //   key,
      //   value,
      //   diff
      // }));

      new SparklineTableCard(this.container, nestData, {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "contracts_sector"
      });

      /* Sparklines */
      var opts = {
        trend: this.trend,
        freq: this.freq
      };

      const sectors = groupBy(jsonData.data, "sector");
      Object.entries(sectors).forEach(([key, values]) => {
        const sorted = values.sort((a, b) =>
          new Date(a.date) < new Date(b.date) ? 1 : -1
        );

        const spark = new Sparkline(
          `${this.container} .sparkline-${key}`,
          sorted,
          opts
        );

        spark.render();
      });
    });
  }
}
