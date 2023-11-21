import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class IncomeOverviewCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      WITH
      maxyear AS (SELECT max(year) FROM renta_habitante WHERE place_id = ${city_id}
                  AND renta_media_hogar IS NOT NULL)
      SELECT
        1 AS index,
        renta_media_hogar AS value
      FROM renta_habitante
      WHERE place_id = ${city_id}
      AND year = (SELECT * FROM maxyear)
      UNION
      SELECT
        2 AS index,
        avg(renta_media_hogar) AS value
      FROM renta_habitante
      WHERE year = (SELECT * FROM maxyear)
      ORDER BY 1
      `

    this.metadata = window.populateData.endpoint.replace("data.json?sql=", "datasets/renta-habitante/meta")
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var [incomePlace, incomeCountry] = jsonData.data;

      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "income_overview"
      };

      new ComparisonCard(
        this.container,
        incomePlace.value,
        incomeCountry.value,
        opts
      );
    });
  }
}
