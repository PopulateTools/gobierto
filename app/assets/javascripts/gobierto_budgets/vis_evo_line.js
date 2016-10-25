'use strict';

var VisEvoLine = Class.extend({
  init: function(divId, series, current_year) {
    this.container = divId;
    this.data = series;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    //this.data = [{"year":2010,"deviation":0},{"year":2011,"deviation":-3.19},{"year":2012,"deviation":-6.37},{"year":2013,"deviation":-10},{"year":2014,"deviation":10},{"year":2015,"deviation":-7.87}];
    this.dataUrl = null;
    this.classed = "evoline"

    // Chart dimensions
    this.margin = {top: 5, right: 50, bottom: 25, left: 0};
    this.width = this._width();
    this.height = 60 + this.margin.top + this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scale.linear();
    this.yScale = d3.scale.linear();

    this.defaultYDomain = [10,-10];

    // Axis
    this.xAxis = d3.svg.axis().orient('bottom');
    this.yAxis = d3.svg.axis().orient('right');

    // Chart objects
    this.svg = null;
    this.chart = null;

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .classed(this.classed,true)
      .attr('width',this.width)
      .attr('height',this.height);

    //xAxis
    this.svg.append('g')
      .attr('class','x axis');

    //yAxis
    this.svg.append('g')
      .attr('class','y axis');

    //line chart
    this.svg.append("path")
      .datum(this.data)
      .attr("class", "line")

    if(this.currentYear != null) {
      this.svg.selectAll('.year_marker')
            .data([this.currentYear])
            .enter()
          .append('line')
            .attr('class', 'year_marker');
    }

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    d3.json(this.dataUrl, function(error, jsonData) {
      if (error) throw error;

      this.data = jsonData;
      this.updateRender();
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
    this.xScale.domain(d3.extent(this.data.map(function(e) {
      return e.year;
    }))).range([this.margin.left, this.width - this.margin.left - this.margin.right]);

    this.yScale.domain(d3.extent(this.data.map(function(e) {
        return e.deviation;
      }).concat(this._yTickValues())))
      .range([this.height - this.margin.bottom, this.margin.top]);

    this._renderAxis();

    var line = d3.svg.line()
      .x(function(d) { return this.xScale(d.year); }.bind(this))
      .y(function(d) { return this.yScale(d.deviation); }.bind(this));

    this.svg.select('.line')
      .attr("d", line);

    if (this.currentYear != null) {
      console.log(this.svg.select('.year_marker'))
      this.svg.selectAll('.year_marker')
        .attr('x1', function(d) {
          return this.xScale(d); }.bind(this))
        .attr('y1', 0)
        .attr('x2', function(d) { return this.xScale(d); }.bind(this))
        .attr('y2', this.height - this.margin.bottom + 10)
    }
  },
  _renderAxis: function() {

    //position axis
    this.svg.select('.x.axis')
      .attr("transform", "translate("+ this.margin.left + "," + (this.height - this.margin.bottom + 10) + ")");

    this.svg.select('.y.axis')
      .attr("transform", "translate(" + (this.width - this.margin.right + 10) + "," + 0 + ")");

    this.xAxis.tickValues(this.data.filter(function(d) {
      return d.year % 2 !== 0;
    }).map(function(d) {
      return d.year;
    }));

    this.xAxis.tickSize(0,0);
    this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.xAxis.scale(this.xScale);
    this.svg.select(".x.axis").call(this.xAxis);

    this.yAxis.tickSize(-this.width,0);
    this.yAxis.tickValues(this._yTickValues());
    this.yAxis.tickFormat(this._formatNumberY.bind(this));
    this.yAxis.scale(this.yScale);
    this.svg.select(".y.axis").call(this.yAxis);
  },
  _axisRendered: function() {
    return this.svg.selectAll('.axis').size() > 0;
  },
  _yTickValues: function() {
    var max_abs = Math.round(d3.max(this.data.map(function(e) {
        return Math.abs(e.deviation);
      })));
    var edge, lower_edge;
    if(max_abs > 100) {
      edge = ((max_abs % 100) < 50) ? Math.floor(max_abs/100) * 100 : (Math.floor(max_abs/100) + 1) * 100;
      lower_edge = -100;
    } else if (max_abs < 10) {
      edge = 10
    } else if (max_abs % 10 < 5) {
      edge = Math.floor(max_abs/10) * 10
    } else {
      edge = (Math.floor(max_abs/10) + 1) * 10
    }
    if (lower_edge === undefined) lower_edge = -edge;
    return [edge, 0, lower_edge];
  },
  _formatNumberX: function(d) {
    //replace with whatever format you want
    //examples here: http://koaning.s3-website-us-west-2.amazonaws.com/html/d3format.html
    return d3.format()(d)
  },
  _formatNumberY: function(d) {
    //replace with whatever format you want
    //examples here: http://koaning.s3-website-us-west-2.amazonaws.com/html/d3format.html
    return d3.format('%')(d/100)
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _resize: function() {
    this.width = this._width();
    // this.height = this._width();
    this.svg.attr('width',this.width)
      .attr('height',this.height);

    this.updateRender();
  }
});