import * as d3 from 'd3'
import { Card } from './card.js'
import { Sparkline, SparklineTableCard } from 'lib/visualizations'

export class UnemplBySectorCard extends Card {
  constructor(divClass, city_id) {
    super(divClass)

    this.url = window.populateData.endpoint + '/datasets/ds-personas-paradas-municipio-sector.json?sort_desc_by=date&with_metadata=true&limit=50&filter_by_location_id=' + city_id;
  }

  getData() {
    var data = d3.json(this.url)
      .header('authorization', 'Bearer ' + this.tbiToken);

    d3.queue()
      .defer(data.get)
      .await(function (error, jsonData) {
        if (error) throw error;

        this.data = jsonData.data;

        this.nest = d3.nest()
          .key(function(d) { return d.sector; })
          .rollup(function(v) { return {
              value: v[0].value,
              diff: (v[0].value - v[1].value) / v[1].value * 100,
            };
          })
          .entries(this.data);

        this.nest = this.nest.filter(function(d) { return d.key !== 'Sin empleo anterior'; });

        this.nest.forEach(function(d) {
          d.key = d.key,
          d.diff = d.value.diff,
          d.value = d.value.value
        }.bind(this));

        new SparklineTableCard(this.container, jsonData, this.nest, 'unemployed_sector');

        /* Sparklines */
        var ind = jsonData.data.filter(function(d) { return d.sector === 'Industria'; });
        var serv = jsonData.data.filter(function(d) { return d.sector === 'Servicios'; });
        var agr = jsonData.data.filter(function(d) { return d.sector === 'Agricultura'; });
        var cons = jsonData.data.filter(function(d) { return d.sector === 'Construcción'; });

        var indSpark = new Sparkline(this.container + ' .sparkline-industria', ind, this.trend, this.freq);
        var servSpark = new Sparkline(this.container + ' .sparkline-servicios', serv, this.trend, this.freq);
        var agrSpark = new Sparkline(this.container + ' .sparkline-agricultura', agr, this.trend, this.freq);
        var consSpark = new Sparkline(this.container + ' .sparkline-construccion', cons, this.trend, this.freq);

        indSpark.render();
        servSpark.render();
        agrSpark.render();
        consSpark.render();
      }.bind(this));
  }
}
