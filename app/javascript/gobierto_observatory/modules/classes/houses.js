import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class HousesCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.famUrl =
      window.populateData.endpoint +
      "/datasets/ds-viviendas-municipales-familiares.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.mainUrl =
      window.populateData.endpoint +
      "/datasets/ds-viviendas-municipales-principales.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
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
