import { ComparisonCard } from "lib/visualizations";
import { Card } from "./card.js";

export class IncomeOverviewCard extends Card {
  constructor(divClass) {
    super(divClass);

    this.incomeProvinceUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-bruta-media-provincial.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      window.populateData.provinceId;
    this.incomeCountryUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-bruta-media-nacional.json?sort_desc_by=date&with_metadata=true&limit=1";
  }

  getData() {
    var incomeProvince = this.handlePromise(this.incomeProvinceUrl);
    var incomeCountry = this.handlePromise(this.incomeCountryUrl);

    Promise.all([incomeProvince, incomeCountry]).then(
      ([incomeProvince, incomeCountry]) => {
        var valueOne = incomeProvince.data[0].value;
        var valueTwo = incomeCountry.data[0].value;

        new ComparisonCard(
          this.container,
          incomeProvince,
          valueOne,
          valueTwo,
          "income_overview"
        );
      }
    );
  }
}
