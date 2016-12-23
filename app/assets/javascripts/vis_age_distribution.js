'use strict';

var VisAgeDistribution = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.classed = 'agedb';
    this.city = city_id;
    this.dataUrl = 'https://tbi.populate.tools/gobierto/datasets/ds-poblacion-municipal-edad.json?sort_asc_by=date&filter_by_year=2015&filter_by_location_id=39075'
    
    // Chart dimensions
    this.margin = {top: 5, right: 0, bottom: 25, left: 0};
    this.width = this._width();
    this.height = 560 + this.margin.top + this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleBand()
        .rangeRound([0, this.width])
        .padding(0.1);
        
    this.yScale = d3.scaleLinear()
        .range([this.height, 0]);

    // Axis
    this.xAxis = d3.axisBottom()

    // Chart objects
    this.svg = null;
    this.chart = null;

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .classed(this.classed,true)
      .attr('width',this.width)
      .attr('height',this.height)
      .append("g")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");

    //xAxis
    this.svg.append('g')
      .attr('class','x axis');

    //yAxis
    this.svg.append('g')
      .attr('class','y axis');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    d3.json(this.dataUrl)
      .header('authorization', 'Bearer WxVwwI-uTEVzvP6RF8FiFg')
      .header('origin', 'http://localhost')
      .get(function(error, jsonData) {
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
    // this.xScale.domain(this.data.map(function(d) {return d.age}))
    // this.yScale.domain([0, d3.max(this.data, function(d) {return d.value})])

    this.xScale.domain(["1", "10", "54"])
    this.yScale.domain([0, 3000])

    this._renderAxis();
        
    var bars = this.svg.append("g")
        .attr("class", "bars")
        .selectAll("rect")
        .data(this.data)
        .enter()
        .append("g")
        .attr("class", "bar");

    // Append bars
    bars.append("rect")
        .attr("x", function(d) { return this.xScale(d.age) }.bind(this))
        .attr("y", function(d) { return this.yScale(d.value) }.bind(this))
        .attr("width", this.xScale.bandwidth())
        .attr("height", function(d) { return this.height - this.yScale(d.value) }.bind(this));
    
  },
  _renderAxis: function() {

    //position axis
    this.svg.select('.x.axis')
      .attr("transform", "translate("+ this.margin.left + "," + (this.height - this.margin.bottom + 10) + ")");

    this.xAxis.tickSize(0,0);
    this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.xAxis.scale(this.xScale);
    this.svg.select(".x.axis").call(this.xAxis);
  },
  _axisRendered: function() {
    return this.svg.selectAll('.axis').size() > 0;
  },
  _formatNumberX: function(d) {
    //replace with whatever format you want
    //examples here: http://koaning.s3-website-us-west-2.amazonaws.com/html/d3format.html
    return d3.format(",")(d)
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
