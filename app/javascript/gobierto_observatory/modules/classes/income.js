import { rollup } from "d3-array";
import { TableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class IncomeCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.placeGrossUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.bcnGrossUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019"; // TODO: Use Populate Data's related cities API
    this.vlcGrossUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-bruta-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250"; // TODO: Use Populate Data's related cities API
    this.placeNetUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.bcnNetUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019"; // TODO: Use Populate Data's related cities API
    this.vlcNetUrl =
      window.populateData.endpoint +
      "/datasets/ds-renta-disponible-media-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250"; // TODO: Use Populate Data's related cities API
  }

  getData() {
    var placeGross = this.handlePromise(this.placeGrossUrl);
    var bcnGross = this.handlePromise(this.bcnGrossUrl);
    var vlcGross = this.handlePromise(this.vlcGrossUrl);
    var placeNet = this.handlePromise(this.placeNetUrl);
    var bcnNet = this.handlePromise(this.bcnNetUrl);
    var vlcNet = this.handlePromise(this.vlcNetUrl);

    Promise.all([
      placeGross,
      bcnGross,
      vlcGross,
      placeNet,
      bcnNet,
      vlcNet
    ]).then(([placeGross, bcnGross, vlcGross, placeNet, bcnNet, vlcNet]) => {
      // Gross
      placeGross.data.forEach(function(d) {
        d.column = "first_column";
        d.location_name = window.populateData.municipalityName;
        d.kind = "gross";
      });

      bcnGross.data.forEach(function(d) {
        d.column = "second_column";
        d.location_name = "Barcelona";
        d.kind = "gross";
      });

      vlcGross.data.forEach(function(d) {
        d.column = "third_column";
        d.location_name = "Valencia";
        d.kind = "gross";
      });

      // Net
      placeNet.data.forEach(function(d) {
        d.column = "first_column";
        d.location_name = window.populateData.municipalityName;
        d.kind = "net";
      });

      bcnNet.data.forEach(function(d) {
        d.column = "second_column";
        d.location_name = "Barcelona";
        d.kind = "net";
      });

      vlcNet.data.forEach(function(d) {
        d.column = "third_column";
        d.location_name = "Valencia";
        d.kind = "net";
      });

      this.data = placeGross.data.concat(
        bcnGross.data,
        vlcGross.data,
        placeNet.data,
        bcnNet.data,
        vlcNet.data
      );

      this.nest = rollup(
        this.data,
        v => ({
          column: v[0].column,
          key: v[0].location_name,
          valueOne: v.filter(d => d.kind === "gross")[0].value,
          valueTwo: v.filter(d => d.kind === "net")[0].value
        }),
        d => d.location_id
      );

      // Convert map to specific array
      this.nest = Array.from(this.nest, ([key, value]) => ({ key, value }));

      new TableCard(this.container, placeGross, this.nest, "income");
    });
  }
}
