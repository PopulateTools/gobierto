import { BarsCard } from "lib/visualizations";
import { Card } from "./card.js";

export class CarsCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.carsPlaceUrl =
      window.populateData.endpoint +
      "/datasets/ds-vehiculos-municipales-total.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.carsProvinceUrl =
      window.populateData.endpoint +
      "/datasets/ds-vehiculos-provinciales-total.json?sort_desc_by=date&limit=1&filter_by_location_id=" +
      window.populateData.provinceId;
    this.carsCountryUrl =
      window.populateData.endpoint +
      "/datasets/ds-vehiculos-nacionales-total.json?sort_desc_by=date";
    this.popPlaceUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal.json?sort_desc_by=date&limit=1&filter_by_location_id=" +
      city_id;
    this.popProvinceUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&limit=1&&filter_by_year=2015&filter_by_province_id=" +
      window.populateData.provinceId;
    this.popCountryUrl =
      window.populateData.endpoint +
      "/datasets/ds-poblacion-municipal/sum.json?sort_desc_by=date&filter_by_year=2015";
  }

  getData() {
    var carsPlace = this.handlePromise(this.carsPlaceUrl);
    var popPlace = this.handlePromise(this.popPlaceUrl);
    var carsProvince = this.handlePromise(this.carsProvinceUrl);
    var popProvince = this.handlePromise(this.popProvinceUrl);
    var carsCountry = this.handlePromise(this.carsCountryUrl);
    var popCountry = this.handlePromise(this.popCountryUrl);

    Promise.all([
      carsPlace,
      popPlace,
      carsProvince,
      popProvince,
      carsCountry,
      popCountry
    ]).then(
      ([
        carsPlace,
        popPlace,
        carsProvince,
        popProvince,
        carsCountry,
        popCountry
      ]) => {
        carsPlace.data.forEach(function(d) {
          d.date = d.date.slice(0, 4);
          d.figure = d.value / popPlace[0].value;
          d.key = window.populateData.municipalityName;
        });

        carsProvince.forEach(function(d) {
          d.figure = d.value / popProvince.sum;
          d.key = window.populateData.provinceName;
        });

        carsCountry.forEach(function(d) {
          d.figure = d.value / popCountry.sum;
          d.key = I18n.t("country");
        });

        this.data = carsPlace.data.concat(carsProvince, carsCountry);

        new BarsCard(this.container, carsPlace, this.data, "cars");
      }
    );
  }
}
