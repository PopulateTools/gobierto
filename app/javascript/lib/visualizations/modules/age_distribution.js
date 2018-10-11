import * as d3 from 'd3'
import { accounting } from 'lib/shared'

export class VisAgeDistribution {
  constructor(divId, city_id, current_year) {
    this.container = divId;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.tbiToken = window.populateData.token;
    this.dataUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal-edad.json?include=municipality&filter_by_year=' + current_year + '&filter_by_location_id=' + city_id;
    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = {top: 25, right: 10, bottom: 25, left: 15};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleBand()
      .padding(0.1);

    this.yScale = d3.scaleLinear();

    this.color = d3.scaleLinear()
      .range(['#FFE4C4','#d52a59'])
      .interpolate(d3.interpolateHcl);

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

    // Create city name selector
    this.city = d3.selectAll('.js-city-name');

    // Append axes containers
    this.svg.append('g').attr('class','x axis');
    this.svg.append('g').attr('class','y axis');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  }

  getData() {
    d3.json(this.dataUrl)
      .header('authorization', 'Bearer ' + this.tbiToken)
      .get(function(error, jsonData) {
        if (error) throw error;

        this.data = jsonData;

        // Get the city total population
        // var population = d3.sum(this.data, function(d) { return d.value; });

        // Calculate and round the percentage of each age
        this.data.forEach(function(d) {
          // Handle +100 age group string
          isNaN(d.age) ? d.age =+ 100 : d.age;

          d.age = +d.age;
          d.years = +d.age * d.value;
        });

        this.data.sort(function(a, b) { return a.age - b.age; });

        this.updateRender();
        this._renderBars();
        this._renderCityData();
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
      .domain(this.data.map(function(d) {return d.age}));

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0, d3.max(this.data, function(d) {return d.value})]);

    this.color
      .domain([0, d3.max(this.data, function(d) {return d.value})]);

    this._renderAxis();
  }

  _renderBars() {
    // We keep this separate to not create them after every resize
    var bars = this.svg.append('g')
      .attr('class', 'bars')
      .selectAll('rect')
      .data(this.data)
      .enter();

    bars.append('rect')
      .attr('x', function(d) { return this.xScale(d.age) }.bind(this))
      .attr('y', function(d) { return this.yScale(d.value) }.bind(this))
      .attr('width', this.xScale.bandwidth())
      .attr('height', function(d) { return this.height - this.yScale(d.value) }.bind(this))
      .attr('fill', function(d) { return this.color(d.value); }.bind(this))
      .on('mousemove', this._mousemove.bind(this))
      .on('mouseout', this._mouseout.bind(this));

    // Append tooltip group & children
    var focusG = this.svg.append('g')
      .attr('class', 'focus');

    focusG.append('text').attr('class', 'focus-halo');
    focusG.append('text').attr('class', 'focus-text');
  }

  _mousemove(d) {
    // Move the whole group
    this.svg.select('.focus')
      .attr('text-anchor', 'middle')
      .attr('transform', 'translate(' + this.xScale(d.age) + ',' + (this.yScale(d.value) -15) + ')')

    // Fill the halo and the tooltip
    this.svg.select('.focus-halo')
      .attr('stroke', 'white')
      .attr('stroke-width', '2px')
      .text(accounting.formatNumber(d.value, 0) + ' ' + I18n.t('gobierto_common.visualizations.label'));

    this.svg.select('.focus-text')
      .text(accounting.formatNumber(d.value, 0) + ' ' + I18n.t('gobierto_common.visualizations.label'));
  }

  _mouseout() {
    this.svg.select('.focus')
      .attr('transform', 'translate(-100,-100)')
  }

  _renderCityData() {
    // Calculate means and stuff
    var avgAge = d3.sum(this.data, function(d) { return d.years }) / d3.sum(this.data, function(d) { return d.value });

    d3.select('.js-avg-age')
      .text(accounting.formatNumber(avgAge, 1));
  }

  _renderAxis() {
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis.tickPadding(5);
    this.xAxis.tickSize(0, 0);
    this.xAxis.scale(this.xScale);
    this.xAxis.tickFormat(this._formatNumberX.bind(this));
    this.svg.select('.x.axis').call(this.xAxis);

    // We only want multiples of 10 in the x axis
    if (this.isMobile) {
      this.svg.selectAll(".x.axis .tick")
        .filter(function (d) { return d % 20 !== 0;  })
        .remove();
    } else {
      this.svg.selectAll(".x.axis .tick")
        .filter(function (d) { return d % 10 !== 0;  })
        .remove();
    }

    // Y axis
    this.svg.select('.y.axis')
      .attr('transform', 'translate(' + (this.width - 35) + ' ,0)');

    this.yAxis.tickSize(-this.width);
    this.yAxis.scale(this.yScale);
    this.yAxis.ticks(3);
    this.yAxis.tickFormat(this._formatNumberY.bind(this));
    this.svg.select('.y.axis').call(this.yAxis);

    // Remove the zero
    this.svg.selectAll(".y.axis .tick")
      .filter(function (d) { return d === 0;  })
      .remove();
  }

  _formatNumberX(d) {
    // 'Age 100' is aggregated
    if (d === 0) {
      return d + ' ' + I18n.t('gobierto_common.visualizations.axis');
    } else if (d === 100) {
      return d + '+';
    } else {
      return d;
    }
  }

  _formatNumberY(d) {
    // Show percentages
    return accounting.formatNumber(d, 0);
  }

  _width() {
    return parseInt(d3.select(this.container).style('width'));
  }

  _height() {
    return this.isMobile ? 200 : this._width() * 0.25;
  }

  _resize() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    // Update bars
    d3.select('#age_distribution .bars').selectAll('rect')
      .attr('x', function(d) { return this.xScale(d.age) }.bind(this))
      .attr('y', function(d) { return this.yScale(d.value) }.bind(this))
      .attr('width', this.xScale.bandwidth())
      .attr('height', function(d) { return this.height - this.yScale(d.value) }.bind(this));
  }
}
