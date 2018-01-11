'use strict';

var Sparkline = Class.extend({
  init: function(divId, json, trend, freq) {
    this.container = divId;
    this.timeParse = freq === 'daily' ? d3.timeParse('%Y-%m-%d') : freq === 'monthly' ? d3.timeParse('%Y-%m') : d3.timeParse('%Y');
    this.isMobile = window.innerWidth <= 768;
    this.trend = trend;
    this.data = json;

    // Chart dimensions
    this.margin = {top: 5, right: 5, bottom: 5, left: 5};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleTime();
    this.yScale = d3.scaleLinear();
    this.color = d3.scaleOrdinal();

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('class', 'chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  render: function() {
    this._type();
    this.updateRender();
    this._renderLines();
  },
  updateRender: function(callback) {
    this.xScale
      .rangeRound([0, this.width])
      .domain(d3.extent(this.data, function(d) { return d.date; }.bind(this)));

    this.yScale
      .rangeRound([this.height, 0])
      .domain(d3.extent(this.data, function(d) { return d.value; }.bind(this)));
  },
  _renderLines: function() {
    this.line = d3.line()
      .x(function(d) { return this.xScale(d.date); }.bind(this))
      .y(function(d) { return this.yScale(d.value); }.bind(this));

    this.isPositive = this.data[0].value - this.data.slice(-1)[0].value > 0 ? true : false;

    this.svg.append('path')
      .datum(this.data)
      .attr('stroke', this._getColor())
      .attr('d', this.line);

    this.svg.append('circle')
      .attr('cx', function(d) { return this.xScale(this.data[0].date); }.bind(this))
      .attr('cy', function(d) { return this.yScale(this.data[0].value); }.bind(this))
      .attr('r', 2.5)
      .attr('fill', this._getColor());
  },
  _getColor: function() {
    if (this.isPositive && this.trend === 'up' || !this.isPositive && this.trend === 'down') {
      return '#AAC44B';
    } else {
      return '#981F2E';
    }
  },
  _type: function() {
    this.data.forEach(function(d) {
      d.date = this.timeParse(d.date)
    }.bind(this));
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this._width() * 0.2;
  },
  _resize: function() {
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    this.svg.select('path')
      .attr('d', this.line);

    this.svg.select('circle')
      .attr('cx', function(d) { return this.xScale(this.data[0].date); }.bind(this))
      .attr('cy', function(d) { return this.yScale(this.data[0].value); }.bind(this))
  }
});
