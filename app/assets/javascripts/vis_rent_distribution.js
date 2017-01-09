'use strict';

var VisRentDistribution = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.tbiToken = window.tbiToken;
    this.rentUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-renta-bruta-media-municipal.json?filter_by_province_id=' + city_id.slice(0, 2);
    this.popUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-poblacion-municipal.json?filter_by_year=' + current_year + '&filter_by_province_id=' + city_id.slice(0, 2);
    this.formatThousand = d3.format(',.0f');

    // Set default locale
    d3.formatDefaultLocale(es_ES);
    
    // Chart dimensions
    this.margin = {top: 5, right: 10, bottom: 30, left: 5};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleLog();
    this.yScale = d3.scaleLinear();

    this.color = d3.scaleSequential(d3.interpolateInferno);

    // Create axes
    this.xAxis = d3.axisBottom();
    this.yAxis = d3.axisRight();

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

    // Create city name selector
    this.city = d3.selectAll('.js-city-name');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    var rent = d3.json(this.rentUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)
    
    var pop = d3.json(this.popUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)
      
    d3.queue()
      .defer(rent.get)
      .defer(pop.get)
      .await(function (error, rent, pop) {
        if (error) throw error;
        
        rent.forEach(function(d) {
          d.rent = d.value
          
          delete d.value;
        });
        
        this.data = _(rent)
          .concat(rent, pop)
          .groupBy('location_id')
          .map(_.spread(_.merge))
          .filter('rent')
          .value();

        this.updateRender();
        this._renderCircles();
        // this._renderCityData();
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
      .domain(d3.extent(this.data, function(d) {return d.value}));

    this.yScale
      .rangeRound([this.height, 0])
      .domain(d3.extent(this.data, function(d) {return d.rent }));

    this.color.domain(d3.extent(this.data, function(d) {return d.rent }));

    this._renderAxis();
  },
  _renderCircles: function() {
    // We keep this separate to not create them after every resize
    var circles = this.svg.append('g')
      .attr('class', 'circles')
      .selectAll('circle')
      .data(this.data)
      .enter();
    
    circles.append('circle')
      .attr('cx', function(d) { return this.xScale(d.value) }.bind(this))
      .attr('cy', function(d) { return this.yScale(d.rent) }.bind(this))
      .attr('fill', function(d) { return this.color(d.rent) }.bind(this))
      .attr('r', 5);
  },
  _renderAxis: function() {
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis.tickPadding(5);
    this.xAxis.tickSize(0, 0);
    this.xAxis.ticks(2); // FIXME: ticks(3) creates 15 ticks
    this.xAxis.scale(this.xScale);
    this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.svg.select('.x.axis').call(this.xAxis);

    // Y axis
    this.svg.select('.y.axis')
      .attr('transform', 'translate(' + this.width + ' ,0)');
    
    this.yAxis.scale(this.yScale);
    this.yAxis.ticks(4);
    this.yAxis.tickSize(-this.width);
    this.yAxis.tickFormat(this._formatNumberY.bind(this));
    this.svg.select('.y.axis').call(this.yAxis);

    // Place y axis labels on top of ticks
    this.svg.selectAll('.y.axis .tick text')
      .attr('dx', '-4.5em')
      .attr('dy', '-0.55em');
    
    // Remove the zero on the y axis
    this.svg.selectAll(".y.axis .tick")
      .filter(function (d) { return d === 0;  })
      .remove();
  },
  _formatThousandAbbr: function(x) {
    return d3.format('.0f')(x / 1e3) + ' mil';
  },
  _formatAbbreviation: function(x) {
    var v = Math.abs(x);

    return (v >= .9995e4 ? this._formatThousandAbbr : this.formatThousand)(x);
  },
  _formatNumberX: function(d) {
    // Spanish custom thousand separator
    return this._formatAbbreviation(d);
  },
  _formatNumberY: function(d) {
    // Show percentages
    return accounting.formatNumber(d, 0) + '€';
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this._width() * 0.5;
  },
  _resize: function() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom);

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');    
    // 
    // Update bars
    d3.select('#rent_distribution .circles').selectAll('circle')
      .attr('cx', function(d) { return this.xScale(d.value) }.bind(this))
      .attr('cy', function(d) { return this.yScale(d.rent) }.bind(this));
  }
});