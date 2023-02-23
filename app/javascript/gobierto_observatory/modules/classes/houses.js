import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class HousesCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.famUrl =
      window.populateData.endpoint +
      `
      SELECT SUM(total_viviendas_familiares ::integer) AS value
      FROM viviendas
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM viviendas )
      `
    this.mainUrl =
      window.populateData.endpoint +
      `
      SELECT SUM(total_viviendas_principales ::integer) AS value
      FROM viviendas
      WHERE
        place_id = ${city_id} AND
        year = (SELECT max(year) FROM viviendas )
      `
  }

  getData() {
    var fam = this.handlePromise(this.famUrl);
    var main = this.handlePromise(this.mainUrl);

    Promise.all([fam, main]).then(([jsonFamily, jsonMain]) => {
      var familyHouses = jsonFamily.data[0].value;
      var mainHouses = jsonMain.data[0].value;

      new ComparisonCard(
        this.container,
        jsonFamily,
        familyHouses,
        mainHouses,
        "houses"
      );
    });
  }
}
