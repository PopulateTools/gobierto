import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class ConstructionTaxCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.placeTaxUrl =
      window.populateData.endpoint +
      "/datasets/ds-impuestos-instalaciones-obras-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.provinceTaxUrl =
      window.populateData.endpoint +
      "/datasets/ds-impuestos-instalaciones-obras-municipal/average.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_province_id=" +
      window.populateData.provinceId;
  }

  getData() {
    var placeTax = this.handlePromise(this.placeTaxUrl);
    var provinceTax = this.handlePromise(this.provinceTaxUrl);

    Promise.all([placeTax, provinceTax]).then(([placeTax, provinceTax]) => {
      var valueOne = placeTax.data[0].value;
      var valueTwo = provinceTax.average;

      new ComparisonCard(
        this.container,
        placeTax,
        valueOne,
        valueTwo,
        "construction_tax"
      );
    });
  }
}
