'use strict';

var VisLinesExecution = Class.extend({
  init: function(divId) {
    this.container = divId;
    this.data = null;
    this.parseTime = d3.timeParse('%Y-%m-%d');
    this.pctFormat = d3.format('.0%');
    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = {top: 25, right: 50, bottom: 25, left: 385};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleLinear().range([0, this.width]);
    this.yScale = d3.scaleBand().range([this.height, 0]);
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

    this.xAxis = d3.axisTop(this.xScale)
      .tickSize(-this.height)
      .ticks(4)
      .tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d);}.bind(this));

    this.yAxis = d3.axisLeft(this.yScale)
      .tickPadding(10);

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    d3.json('/test_lines.json', function(error, jsonData) {
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
    this.data.lines.sort(function(a ,b) { return a.pct_executed - b.pct_executed;});

    this.xScale.domain([0, 1.15])
    this.yScale.domain(this.data.lines.map(function(d) { return d.name; })).padding(0.1);

    /* Background bar */
    this.svg.selectAll('.bar-bg')
      .data(this.data.lines)
      .enter()
      .append('rect')
      .attr('class', 'bar-bg')
      .attr('x', 0)
      .attr('height', this.yScale.bandwidth())
      .attr('y', function(d) { return this.yScale(d.name); }.bind(this))
      .attr('width', function(d) { return this.xScale(1.15); }.bind(this))
      .attr('fill', '#efefef')
      .on('mousemove', function(d) { d3.select(this).attr('stroke', 'black') })
   	  .on('mouseout', function(d) { d3.select(this).attr('stroke', 'none') });

    /* Main bar */
    this.svg.selectAll('.bar')
      .data(this.data.lines)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', 0)
      .attr('height', this.yScale.bandwidth())
      .attr('y', function(d) { return this.yScale(d.name); }.bind(this))
      .attr('width', function(d) { return this.xScale(d.pct_executed); }.bind(this))
      .attr('fill', '#00909e')

    this.svg.append('g')
      .attr('class', 'x axis')
    	.call(this.xAxis)

    this.svg.append('g')
     .attr('class', 'y axis')
     .call(this.yAxis);

    var lines = d3.select(this.container)
      .selectAll('div')
      .data(this.data.lines)
      .enter()
      .append('div')
      .text(function(d) { return d.name;})

    lines.selectAll('div')
      .data(function(d) { return d.child_lines;})
      .enter()
      .append('div')
      .text(function(d) { return d.name;})
      .style('padding-left', '1em')
  },
  _renderAxis: function() {

  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this.isMobile ? 200 : this._width() * 0.25;
  },
  _resize: function() {

  }
});
