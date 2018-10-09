import * as d3 from 'd3'

export class VisUnemploymentSex {
  constructor(divId, city_id, unemplAgeData) {
    this.location_id = parseInt(city_id);
    this.container = divId;
    this.data = null;
    this.unemplAgeData = unemplAgeData;
    this.tbiToken = window.populateData.token;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-activa-municipal-sexo.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.unemplUrl = window.populateData.endpoint + '/datasets/ds-personas-paradas-municipio-sexo.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.parseTime = d3.timeParse('%Y-%m');
    this.pctFormat = d3.format('.1%');
    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = {top: 25, right: 50, bottom: 25, left: 20};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleTime();
    this.yScale = d3.scaleLinear();
    this.color = d3.scaleOrdinal();

    // Create axes
    this.xAxis = d3.axisBottom();
    this.yAxis = d3.axisLeft();

    // Chart objects
    this.svg = null;
    this.chart = null;

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('class', 'chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    // Append axes containers
    this.svg.append('g').attr('class','x axis');
    this.svg.append('g').attr('class','y axis');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  }

  getData() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    var unemployed = d3.json(this.unemplUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .defer(unemployed.get)
      .await(function (error, population, unemployment) {
        if (error) throw error;

        if(this.location_id === 8077) {
          let factor = 0.7786712568;
          population.forEach((d) => {
            d.value = d.value * factor;
          })
        }

        var nested = d3.nest()
          .key(function(d) { return d.date; })
          .rollup(function(v) { return d3.sum(v, function(d) { return d.value; }); })
          .entries(population);

        var temp = {};
        nested.forEach(function(k) {
          temp[k.key] = k.value
        });
        nested = temp;

        // Get the last year from the array
        var lastYear = unemployment[unemployment.length - 1].date.slice(0,4);

        unemployment.forEach(function(d) {
          var year = d.date.slice(0,4);

          if(nested.hasOwnProperty(year)) {
            d.pct = d.value / nested[year]
          } else if(year === lastYear) {
            // If we are in the last year, divide the unemployment by last year's population
            d.pct = d.value / nested[year - 1]
          } else {
            d.pct = null;
          }
          d.date = this.parseTime(d.date);
        }.bind(this));

        // Filtering values to start from the first data points
        this.data = unemployment.filter(function(d) { return d.date >= this.parseTime('2011-01') }.bind(this));

        this.nest = d3.nest()
          .key(function(d) { return d.sex; })
          .entries(this.data);

        this.updateRender();
        this._renderLines();
        this._renderVoronoi();

      }.bind(this));
  }

  render() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  }

  updateRender() {
    this.xScale
      .rangeRound([0, this.width])
      .domain([d3.timeParse('%Y-%m')('2010-11'), d3.max(this.data, function(d) { return d.date; })]);

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0.0, d3.max(this.unemplAgeData, function(d) { return d.pct; })]);

    this.color
      .domain(['M', 'H'])
      .range(['#F6B128','#007382']);

    this._renderAxis();
  }

  _renderLines() {
    this.line = d3.line()
      .x(function(d) { return this.xScale(d.date); }.bind(this))
      .y(function(d) { return this.yScale(d.pct); }.bind(this));

      var lines = this.svg.append('g')
        .attr('class', 'lines')
        .selectAll('path')
        .data(this.nest, function(d) { return d.key; })
        .enter();

      var linesGroup = lines.append('g')
        .attr('class', 'line');

      linesGroup.append('path')
        .attr('d', function(d) { d.line = this; return this.line(d.values); }.bind(this))
        .attr('stroke', function(d) { return this.color(d.key); }.bind(this));

      linesGroup.append('circle')
       .attr('cx', function(d) { return this.xScale(d.values.map(function(d) { return d.date; }).slice(-1)[0]); }.bind(this))
       .attr('cy', function(d) { return this.yScale(d.values.map(function(d) { return d.pct; }).slice(-1)[0]); }.bind(this))
       .attr('r', 5)
       .attr('fill', function(d) { return this.color(d.key); }.bind(this));

      var linesText = d3.select(this.container).append('div')
        .attr('class', 'lines-labels')
        .selectAll('p')
        .data(this.nest, function(d) { return d.key; })
        .enter();

      linesText.append('div')
        .style('right', '1px')
        .style('top', function(d) { return this.yScale(d.values.map(function(d) { return d.pct; }).slice(-1)[0]) + 'px'; }.bind(this))
        .text(function(d) {
          return this._getLabel(d.key);
        }.bind(this));
  }

  _renderVoronoi() {
    // Voronoi
    this.focus = this.svg.append('g')
        .attr('transform', 'translate(-100,-100)')
        .attr('class', 'focus');

    this.focus.append('circle')
        .attr('fill', 'white')
        .attr('r', 5);

    this.text = this.focus
      .append('text')

    this.text.append('tspan')
        .attr('y', -10)
        .attr('x', 0);

    this.voronoi = d3.voronoi()
        .x(function(d) {return this.xScale(d.date); }.bind(this))
        .y(function(d) {return this.yScale(d.pct); }.bind(this))
        .extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup = this.svg.append('g')
        .attr('class', 'voronoi');

    this.voronoiGroup.selectAll('path')
        .data(this.voronoi.polygons(d3.merge(this.nest.map(function(d) { return d.values; }))))
        .enter().append('path')
        .attr('d', function(d) { return d ? 'M' + d.join('L') + 'Z' : null; })
        .on('mouseover', this._mouseover.bind(this))
        .on('mouseout', this._mouseout.bind(this));
  }

  _mouseover(d) {
    this.focus.select('circle').attr('stroke', this.color(d.data.sex));
    this.focus.attr('transform', 'translate(' + this.xScale(d.data.date) + ',' + this.yScale(d.data.pct) + ')');
    this.focus.select('text').attr('text-anchor', d.data.date >= this.parseTime('2014-01') ? 'end' : 'start');
    this.focus.select('tspan').text(`${this._getLabel(d.data.sex)}: ${this.pctFormat(d.data.pct)} (${d.data.date.toLocaleString(I18n.locale, {month: 'short'})} ${d.data.date.getFullYear()})`);
  }

  _mouseout() {
    this.focus.attr('transform', 'translate(-100,-100)');
  }

  _getLabel(sex) {
    switch (sex) {
      case 'H':
        return I18n.t('gobierto_common.visualizations.men');
      case 'M':
        return I18n.t('gobierto_common.visualizations.women');
    }
  }

  _renderAxis() {
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis
      .tickPadding(5)
      .tickSize(0, 0)
      .ticks(4)
      .scale(this.xScale);

    this.svg.select('.x.axis').call(this.xAxis);

    // Y axis
    this.yAxis
      .tickSize(-this.width)
      .scale(this.yScale)
      .ticks(3, '%');

    this.svg.select('.y.axis').call(this.yAxis);

    // Remove the zero
    this.svg.selectAll(".y.axis .tick")
      .filter(function (d) { return d === 0;  })
      .remove();

    // Move y axis ticks on top of the chart
    this.svg.selectAll('.y.axis .tick text')
      .attr('text-anchor', 'start')
      .attr('dx', '0.25em')
      .attr('dy', '-0.55em');
  }

  _width() {
    return parseInt(d3.select(this.container).style('width'));
  }

  _height() {
    return this.isMobile ? 200 : 250;
  }

  _resize() {
    this.isMobile = window.innerWidth <= 768;

    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom);

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    this.svg.selectAll('.lines path')
      .attr('d', function(d) { d.line = this; return this.line(d.values); }.bind(this));

    this.svg.selectAll('.lines circle')
      .attr('cx', function(d) { return this.xScale(d.values.map(function(d) { return d.date; }).slice(-1)[0]); }.bind(this))
      .attr('cy', function(d) { return this.yScale(d.values.map(function(d) { return d.pct; }).slice(-1)[0]); }.bind(this));

    d3.selectAll(this.container + ' .lines-labels div')
      .style('top', function(d) { return this.yScale(d.values.map(function(d) { return d.pct; }).slice(-1)[0]) + 'px'; }.bind(this));

    this.voronoi
      .extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup.selectAll('path')
      .data(this.voronoi.polygons(d3.merge(this.nest.map(function(d) { return d.values; }))))
      .attr('d', function(d) { return d ? 'M' + d.join('L') + 'Z' : null; });
  }

}
