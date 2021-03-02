import { nest } from "d3-collection";
import { Sparkline, SparklineTableCard } from "lib/visualizations";
import { Card } from "./card.js";

export class UnemplBySectorCard extends Card {
  constructor(divClass, city_id) {
    super(divClass);

    this.url =
      window.populateData.endpoint +
      "/datasets/ds-personas-paradas-municipio-sector.json?sort_desc_by=date&with_metadata=true&limit=50&filter_by_location_id=" +
      city_id;
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(jsonData => {
      this.data = jsonData.data;

      // d3v5
      //
      this.nest = nest()
        .key(function(d) {
          return d.sector;
        })
        .rollup(function(v) {
          return {
            value: v[0].value,
            diff: ((v[0].value - v[1].value) / v[1].value) * 100
          };
        })
        .entries(this.data);

      this.nest.forEach(function(d) {
          d.diff = d.value.diff;
          d.value = d.value.value;
        }.bind(this)
      );

      // d3v6
      //
      // this.nest = rollup(
      //   this.data,
      //   v => ({
      //     value: v[0].value,
      //     diff: ((v[0].value - v[1].value) / v[1].value) * 100
      //   }),
      //   d => d.sector
      // );

      // // Convert map to specific array
      // this.nest = Array.from(this.nest, ([key, { value, diff }]) => ({
      //   key,
      //   value,
      //   diff
      // }));

      this.nest = this.nest.filter(d => d.key !== "Sin empleo anterior");

      new SparklineTableCard(
        this.container,
        jsonData,
        this.nest,
        "unemployed_sector"
      );

      /* Sparklines */
      var ind = jsonData.data.filter(d => d.sector === "Industria");
      var serv = jsonData.data.filter(d => d.sector === "Servicios");
      var agr = jsonData.data.filter(d => d.sector === "Agricultura");
      var cons = jsonData.data.filter(d => d.sector === "Construcción");

      var opts = {
        trend: this.trend,
        freq: this.freq
      };

      var indSpark = new Sparkline(
        this.container + " .sparkline-industria",
        ind,
        opts
      );
      var servSpark = new Sparkline(
        this.container + " .sparkline-servicios",
        serv,
        opts
      );
      var agrSpark = new Sparkline(
        this.container + " .sparkline-agricultura",
        agr,
        opts
      );
      var consSpark = new Sparkline(
        this.container + " .sparkline-construccion",
        cons,
        opts
      );

      indSpark.render();
      servSpark.render();
      agrSpark.render();
      consSpark.render();
    });
  }
}
