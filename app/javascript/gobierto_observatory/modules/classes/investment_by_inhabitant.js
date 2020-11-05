import { rollup } from "d3-array";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class InvestmentByInhabitantCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-inversion-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_municipality_id=" +
      city_id;
    this.bcnUrl =
      window.populateData.endpoint +
      "/datasets/ds-inversion-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_municipality_id=08019"; // TODO: Use Populate Data's related cities API
    this.vlcUrl =
      window.populateData.endpoint +
      "/datasets/ds-inversion-por-habitante.json?sort_desc_by=date&with_metadata=true&limit=2&filter_by_municipality_id=46250"; // TODO: Use Populate Data's related cities API
  }

  getData() {
    var data = this.handlePromise(this.url);
    var bcn = this.handlePromise(this.bcnUrl);
    var vlc = this.handlePromise(this.vlcUrl);

    Promise.all([data, bcn, vlc]).then(([json, bcn, vlc]) => {
      json.data.forEach(function(d) {
        d.location_name = window.populateData.municipalityName;
        d.row = "first_column";
      });

      bcn.data.forEach(function(d) {
        d.location_name = "Barcelona";
        d.row = "second_column";
      });

      vlc.data.forEach(function(d) {
        d.location_name = "Valencia";
        d.row = "third_column";
      });

      this.data = json.data.concat(bcn.data, vlc.data);

      this.nest = rollup(
        this.data,
        v => ({
          value: v[0].value,
          diff: ((v[0].value - v[1].value) / v[1].value) * 100
        }),
        d => d.row
      );

      // Convert map to specific array
      this.nest = Array.from(this.nest, ([key, { value, diff }]) => ({
        key,
        value,
        diff
      }));

      new SparklineTableCard(
        this.container,
        json,
        this.nest,
        "investment_by_inhabitant"
      );

      /* Sparklines */
      var place = this.data.filter(
        d => d.location_name === window.populateData.municipalityName
      );
      bcn = this.data.filter(d => d.location_name === "Barcelona");
      vlc = this.data.filter(d => d.location_name === "Valencia");

      var opts = {
        trend: this.trend,
        freq: this.freq
      };

      var placeSpark = new Sparkline(
        this.container + " .sparkline-first_column",
        place,
        opts
      );
      var bcnSpark = new Sparkline(
        this.container + " .sparkline-second_column",
        bcn,
        opts
      );
      var vlcSpark = new Sparkline(
        this.container + " .sparkline-third_column",
        vlc,
        opts
      );

      placeSpark.render();
      bcnSpark.render();
      vlcSpark.render();
    });
  }
}
