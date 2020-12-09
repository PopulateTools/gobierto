import { nest } from "d3-collection";
import { TableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class IbiCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.placeIbiCUrl =
      window.populateData.endpoint +
      "/datasets/ds-ibi-vivienda-urbana-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.bcnIbiCUrl =
      window.populateData.endpoint +
      "/datasets/ds-ibi-vivienda-urbana-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019"; // TODO: Use Populate Data's related cities API
    this.vlcIbiCUrl =
      window.populateData.endpoint +
      "/datasets/ds-ibi-vivienda-urbana-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250"; // TODO: Use Populate Data's related cities API
    this.placeIbiRUrl =
      window.populateData.endpoint +
      "/datasets/ds-ibi-vivienda-rustica-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=" +
      city_id;
    this.bcnIbiRUrl =
      window.populateData.endpoint +
      "/datasets/ds-ibi-vivienda-rustica-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=08019"; // TODO: Use Populate Data's related cities API
    this.vlcIbiRUrl =
      window.populateData.endpoint +
      "/datasets/ds-ibi-vivienda-rustica-municipal.json?sort_desc_by=date&with_metadata=true&limit=1&filter_by_location_id=46250"; // TODO: Use Populate Data's related cities API
  }

  getData() {
    var placeIbiC = this.handlePromise(this.placeIbiCUrl);
    var bcnIbiC = this.handlePromise(this.bcnIbiCUrl);
    var vlcIbiC = this.handlePromise(this.vlcIbiCUrl);
    var placeIbiR = this.handlePromise(this.placeIbiRUrl);
    var bcnIbiR = this.handlePromise(this.bcnIbiRUrl);
    var vlcIbiR = this.handlePromise(this.vlcIbiRUrl);

    Promise.all([
      placeIbiC,
      bcnIbiC,
      vlcIbiC,
      placeIbiR,
      bcnIbiR,
      vlcIbiR
    ]).then(([placeIbiC, bcnIbiC, vlcIbiC, placeIbiR, bcnIbiR, vlcIbiR]) => {
      // City tax
      placeIbiC.data.forEach(function(d) {
        d.column = "first_column";
        d.location_name = window.populateData.municipalityName;
        d.kind = "city";
      });

      bcnIbiC.data.forEach(function(d) {
        d.column = "second_column";
        d.location_name = "Barcelona";
        d.kind = "city";
      });

      vlcIbiC.data.forEach(function(d) {
        d.column = "third_column";
        d.location_name = "Valencia";
        d.kind = "city";
      });

      // Rustic tax
      placeIbiR.data.forEach(function(d) {
        d.column = "first_column";
        d.location_name = window.populateData.municipalityName;
        d.kind = "rustic";
      });

      bcnIbiR.data.forEach(function(d) {
        d.column = "second_column";
        d.location_name = "Barcelona";
        d.kind = "rustic";
      });

      vlcIbiR.data.forEach(function(d) {
        d.column = "third_column";
        d.location_name = "Valencia";
        d.kind = "rustic";
      });

      this.data = placeIbiC.data.concat(
        bcnIbiC.data,
        vlcIbiC.data,
        placeIbiR.data,
        bcnIbiR.data,
        vlcIbiR.data
      );

      // d3v5
      //
      this.nest = nest()
        .key(function(d) {
          return d.location_id;
        })
        .rollup(function(v) {
          return {
            column: v[0].column,
            key: v[0].location_name,
            valueOne: v.filter(function(d) {
              return d.kind === "city";
            })[0].value,
            valueTwo: v.filter(function(d) {
              return d.kind === "rustic";
            })[0].value
          };
        })
        .entries(this.data);

      // d3v6
      //
      // this.nest = rollup(
      //   this.data,
      //   v => ({
      //     column: v[0].column,
      //     key: v[0].location_name,
      //     valueOne: v.filter(d => d.kind === "city")[0].value,
      //     valueTwo: v.filter(d => d.kind === "rustic")[0].value
      //   }),
      //   d => d.location_id
      // );
      // // Convert map to specific array
      // this.nest = Array.from(this.nest, ([key, value]) => ({ key, value }));

      new TableCard(this.container, placeIbiC, this.nest, "ibi");
    });
  }
}
