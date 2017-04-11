'use strict';

var VisUnemploymentSectors = Class.extend({
  init: function(divId, city_id) {
    this.container = divId;
    this.data = null;
    this.tbiToken = window.populateData.token;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal-edad.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.sectorsUrl = window.populateData.endpoint + '/datasets/ds-personas-paradas-municipio-sector.json?sort_asc_by=date&filter_by_location_id=' + city_id;
    this.timeFormat = d3.timeParse('%Y-%m');
    this.pctFormat = d3.format('.1%');
    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = {top: 25, right: 10, bottom: 25, left: 0};
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
  },
  getData: function() {
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    var sectors = d3.json(this.sectorsUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)

    d3.queue()
      .defer(pop.get)
      .defer(sectors.get)
      .await(function (error, jsonData, sectors) {
        if (error) throw error;

        var nested = d3.nest()
          .key(function(d) { return d.date; })
          .rollup(function(v) { return d3.sum(v, function(d) { return d.value; }); })
          .entries(jsonData);

        var temp = {};
        nested.forEach(function(k) {
          temp[k.key] = k.value
        });
        nested = temp;

        // Get the last year from the array
        var lastYear = sectors[sectors.length - 1].date.slice(0,4);

        sectors.forEach(function(d) {
          var year = d.date.slice(0,4);

          if(nested.hasOwnProperty(year)) {
            d.pct = d.value / nested[year]
          } else if(year === lastYear) {
            // If we are in the last year, divide the unemployment by last year's population
            d.pct = d.value / nested[year - 1]
          } else {
            d.pct = null;
          }
          d.date = this.timeFormat(d.date);
        }.bind(this));

        // Filtering values to start from the first data points
        this.data = sectors.filter(function(d) { return d.date >= this.timeFormat('2011-01') }.bind(this));

        this.nest = d3.nest()
          .key(function(d) { return d.sector; })
          .entries(this.data);

        this.updateRender();
        this._renderLines();
        this._renderVoronoi();

      }.bind(this));
  },
  render: function() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  },
  updateRender: function(callback) {
    this.xScale
      .rangeRound([0, this.width])
      .domain([d3.timeParse('%Y-%m')('2010-11'), d3.max(this.data, function(d) { return d.date; })]);

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0, 0.137]);

    this.color
      .domain(['Agricultura', 'Industria', 'Construcción', 'Servicios', 'Sin empleo anterior'])
      .range(['#66c2a5','#fc8d62','#8da0cb','#e78ac3','#a6d854']);

    this._renderAxis();
  },
  _renderLines: function() {
    this.line = d3.line()
      .x(function(d) { return this.xScale(d.date); }.bind(this))
      .y(function(d) { return this.yScale(d.pct); }.bind(this));

    this.svg.append('g')
      .attr('class', 'lines')
      .selectAll('path')
      .data(this.nest, function(d) { return d.key; })
      .enter()
      .append('path')
      .attr('class', 'line')
      .attr('d', function(d) { d.line = this; return this.line(d.values); }.bind(this))
      .attr('stroke', function(d) { return this.color(d.key); }.bind(this));
  },
  _renderVoronoi: function() {
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
  },
  _mouseover: function(d) {
    this.focus.select('circle').attr('stroke', this.color(d.data.sector));
    this.focus.attr('transform', 'translate(' + this.xScale(d.data.date) + ',' + this.yScale(d.data.pct) + ')');
    this.focus.select('text').attr('text-anchor', d.data.date >= this.timeFormat('2014-01') ? 'end' : 'start');
    this.focus.select('tspan').text(d.data.sector + ': ' + this.pctFormat(d.data.pct));
  },
  _mouseout: function(d) {
    this.focus.attr('transform', 'translate(-100,-100)');
  },
  _renderAxis: function() {
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis.tickPadding(5);
    this.xAxis.tickSize(0, 0);
    this.xAxis.scale(this.xScale);
    // this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.svg.select('.x.axis').call(this.xAxis);

    // Y axis
    this.yAxis.tickSize(-this.width);
    this.yAxis.scale(this.yScale);
    this.yAxis.ticks(3, '%');
    // this.yAxis.tickFormat(this._formatNumberY.bind(this));
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
  },
  _formatNumberX: function(d) {
  },
  _formatNumberY: function(d) {
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this.isMobile ? 200 : this._width() * 1.4;
  },
  _resize: function() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    this.svg.selectAll('.lines path')
      .attr('d', function(d) { d.line = this; return this.line(d.values); }.bind(this));

    this.voronoi
    .extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup.selectAll("path")
      .data(this.voronoi.polygons(d3.merge(this.nest.map(function(d) { return d.values; }))))
      .attr('d', function(d) { return d ? 'M' + d.join('L') + 'Z' : null; });
  }
});
