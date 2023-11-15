import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";
import { getMetadataFields } from "../helpers.js";

export class HousesCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      `
      SELECT SUM(total_viviendas_familiares ::integer) AS value
      FROM viviendas
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM viviendas )
      UNION
      SELECT SUM(total_viviendas_principales ::integer) AS value
      FROM viviendas
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM viviendas )
      `;

    this.metadata = window.populateData.endpoint.replace(
      "data.json?sql=",
      "datasets/viviendas/meta"
    );
  }

  getData() {
    var data = this.handlePromise(this.url);
    var metadata = this.handlePromise(this.metadata);

    Promise.all([data, metadata]).then(([jsonData, jsonMetadata]) => {
      var [familyHouses, mainHouses] = jsonData.data;

      var opts = {
        metadata: getMetadataFields(jsonMetadata),
        cardName: "houses"
      };

      new ComparisonCard(
        this.container,
        familyHouses.value,
        mainHouses.value,
        opts
      );
    });
  }
}
