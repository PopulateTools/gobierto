import { BarsCard } from "lib/visualizations";
import { Card } from "./card.js";

export class DebtByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-deuda-municipal.json?divided_by=ds-poblacion-municipal&sort_desc_by=date&with_metadata=true&filter_by_location_id=" +
      city_id;
    this.bcnUrl =
      window.populateData.endpoint +
      "/datasets/ds-deuda-municipal.json?divided_by=ds-poblacion-municipal&sort_desc_by=date&with_metadata=true&filter_by_location_id=08019"; // TODO: Use Populate Data's related cities API
    this.vlcUrl =
      window.populateData.endpoint +
      "/datasets/ds-deuda-municipal.json?divided_by=ds-poblacion-municipal&sort_desc_by=date&with_metadata=true&filter_by_location_id=46250"; // TODO: Use Populate Data's related cities API
  }

  getData() {
    var data = this.handlePromise(this.url);
    var bcn = this.handlePromise(this.bcnUrl);
    var vlc = this.handlePromise(this.vlcUrl);

    Promise.all([data, bcn, vlc]).then(([json, bcn, vlc]) => {
      json.data.forEach(function(d) {
        d.figure = d.divided_by_value;
        d.key = window.populateData.municipalityName;
      });

      bcn.data.forEach(function(d) {
        d.figure = d.divided_by_value;
        d.key = "Barcelona";
      });

      vlc.data.forEach(function(d) {
        d.figure = d.divided_by_value;
        d.key = "Valencia";
      });

      this.data = [json.data[0], bcn.data[0], vlc.data[0]];

      new BarsCard(this.container, json, this.data, "debt_by_inhabitant");
    });
  }
}
