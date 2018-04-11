import { Class, accounting, d3 } from 'shared'

export var VisAgeReport = Class.extend({
  init: function(divId, url) {
    this.container = divId;
    this.data = null;
    this.ageGroups = null;
    this.dataUrl = url;
    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = {top: 25, right: 10, bottom: 25, left: 15};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleBand()
      .padding(0.3);

    this.yScale = d3.scaleLinear();

    // this.color = d3.scaleSequential(d3.interpolateWarm);

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

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    d3.csv(this.dataUrl)
      .get(function(error, csvData) {
        if (error) throw error;

        // Main dataset
        this.data = csvData;
        this.data.forEach(function(d) {
          d.age = +d.age
          d.answer = +d.answer
          d.id = +d.id
        });

        // Make an object for each participant
        var nested = d3.nest()
          .key(function(d) { return d.id })
          .entries(this.data);

        // Gather total participations
        var total = nested.length;

        // Assign people to age groups
        this.ageGroups = d3.nest()
          .rollup(function(v) { return [
              {
                'age_group': '16-24',
                'response_rate': +accounting.toFixed(_.uniq(v.filter(function(d) { return d.age >= 16 && d.age <= 24 }).map(function(d) { return d.id })).length / total, 4),
              },
              {
                'age_group': '25-34',
                'response_rate': +accounting.toFixed(_.uniq(v.filter(function(d) { return d.age >= 25 && d.age <= 34 }).map(function(d) { return d.id })).length / total, 4),
              },
              {
                'age_group': '35-44',
                'response_rate': +accounting.toFixed(_.uniq(v.filter(function(d) { return d.age >= 35 && d.age <= 44 }).map(function(d) { return d.id })).length / total, 4),
              },
              {
                'age_group': '45-54',
                'response_rate': +accounting.toFixed(_.uniq(v.filter(function(d) { return d.age >= 45 && d.age <= 54 }).map(function(d) { return d.id })).length / total, 4),
              },
              {
                'age_group': '55-64',
                'response_rate': +accounting.toFixed(_.uniq(v.filter(function(d) { return d.age >= 55 && d.age <= 64 }).map(function(d) { return d.id })).length / total, 4),
              },
              {
                'age_group': '65+',
                'response_rate': +accounting.toFixed(_.uniq(v.filter(function(d) { return d.age >= 65 }).map(function(d) { return d.id })).length / total, 4)
              }
            ];
          })
          .entries(this.data);

        this.updateRender();
        this._renderBars();
      }.bind(this));
  },
  render: function() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  },
  updateRender: function() {
    this.xScale
      .rangeRound([0, this.width])
      .domain(this.ageGroups.map(function(d) { return d.age_group }));

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0, d3.max(this.ageGroups, function(d) { return d.response_rate })]);

    this._renderAxis();
  },
  _renderBars: function() {
    // We keep this separate to not create them after every resize
    var barGroup = this.svg.append('g')
      .attr('class', 'bars')
      .selectAll('rect')
      .data(this.ageGroups)
      .enter();

    var bars = barGroup.append('g')
      .attr('transform', function(d) { return 'translate('+ this.xScale(d.age_group) + ',' + this.yScale(d.response_rate) + ')'; }.bind(this));

    bars.append('rect')
      .attr('width', this.xScale.bandwidth())
      .attr('height', function(d) { return this.height - this.yScale(d.response_rate) }.bind(this));

    bars.append('text')
      .attr('text-anchor', 'middle')
      .attr('dy', -5)
      .attr('x', this.xScale.bandwidth() / 2)
      .text(function(d) {
        return d3.format('.0%')(d.response_rate);
      });
  },
  _renderAxis: function() {
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis.tickPadding(5);
    this.xAxis.tickSize(0, 0);
    this.xAxis.scale(this.xScale);
    this.svg.select('.x.axis').call(this.xAxis);

    // Y axis
    this.svg.select('.y.axis')
      .attr('transform', 'translate(' + (this.width - 35) + ' ,0)');

    this.yAxis.tickSize(-this.width);
    this.yAxis.scale(this.yScale);
    this.yAxis.ticks(3);
    this.yAxis.tickFormat(d3.format('.0%'));
    this.svg.select('.y.axis').call(this.yAxis);

    // Remove the zero
    this.svg.selectAll(".y.axis .tick")
      .filter(function (d) { return d === 0;  })
      .remove();
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this.isMobile ? 200 : this._width() * 0.25;
  },
  _resize: function() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)

    this.svg.select(this.container + ' > g')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    // Update bars
    d3.select(this.container + ' .bars').selectAll('g')
      .attr('transform', function(d) { return 'translate('+ this.xScale(d.age_group) + ',' + this.yScale(d.response_rate) + ')'; }.bind(this));

    d3.select(this.container + ' .bars').selectAll('g rect')
      .attr('width', this.xScale.bandwidth())
      .attr('height', function(d) { return this.height - this.yScale(d.response_rate) }.bind(this));

    d3.select(this.container + ' .bars').selectAll('g text')
      .attr('x', this.xScale.bandwidth() / 2)
  }
});
