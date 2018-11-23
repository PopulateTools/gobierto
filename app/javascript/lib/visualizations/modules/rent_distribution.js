import * as __d3 from 'd3'
import { distanceLimitedVoronoi } from './d3-distance-limited-voronoi.js'
import { d3locale, accounting } from 'lib/shared'

const d3 = { ...__d3, distanceLimitedVoronoi }

export class VisRentDistribution {
  constructor(divId, city_id, province_id, current_year) {
    this.container = divId;
    this.cityId = city_id;
    this.provinceId = province_id;
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null;
    this.data = null;
    this.tbiToken = window.populateData.token;
    this.rentUrl = window.populateData.endpoint + '/datasets/ds-renta-bruta-media-municipal.json?include=municipality&filter_by_province_id=' + this.provinceId;
    this.popUrl = window.populateData.endpoint + '/datasets/ds-poblacion-municipal.json?filter_by_year=' + this.currentYear + '&filter_by_province_id=' + this.provinceId;
    this.formatThousand = d3.format(',.0f');
    this.isMobile = window.innerWidth <= 768;

    // Set default locale
    d3.formatDefaultLocale(d3locale[I18n.locale]);

    // Chart dimensions
    this.margin = {top: 25, right: 15, bottom: 30, left: 15};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleLog();
    this.yScale = d3.scaleLinear();

    this.color = d3.scaleSequential(d3.interpolatePlasma);

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

    this.tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  }

  getData() {
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
        this.isMobile ? null : this._renderVoronoi();
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
      .domain(d3.extent(this.data, function(d) { return d.value; }));

    this.yScale
      .rangeRound([this.height, 0])
      .domain(d3.extent(this.data, function(d) { return d.rent; }));

    this.color.domain(d3.extent(this.data, function(d) { return d.rent; }).reverse());

    this._renderAxis();
  }

  _renderCircles() {
    // We keep this separate to not create them after every resize
    var circles = this.svg.append('g')
      .attr('class', 'circles')
      .selectAll('circle')
      .data(this.data)
      .enter();

    circles.append('circle')
      .attr('class', function(d, i) { return d.location_id === +this.cityId ? 'circle' + i + ' selected-city' : 'circle' + i; }.bind(this))
      .attr('cx', function(d) { return this.xScale(d.value) }.bind(this))
      .attr('cy', function(d) { return this.yScale(d.rent) }.bind(this))
      .attr('fill', function(d) { return this.color(d.rent) }.bind(this))
      .attr('stroke', 'white')
      .attr('r', this.isMobile ? 6 : 12);

    // Add name of the current city
    var cityLabel = this.svg.append('g')
      .attr('class', 'text-label');

    // cityLabel.append()

    cityLabel.selectAll('text')
      .data(this.data)
      .enter()
      .filter(function(d) { return d.location_id === +this.cityId; }.bind(this))
      .append('text')
      .attr('x', function(d) { return this.xScale(d.value) }.bind(this))
      .attr('y', function(d) { return this.yScale(d.rent) }.bind(this))
      .attr('dy', 7)
      .attr('dx', -15)
      .attr('text-anchor', 'end')
      .text(function(d) { return d.municipality_name });

  }

  _renderVoronoi() {

    console.log(d3.distanceLimitedVoronoi);
    
    // Create voronoi
    this.voronoi = d3.distanceLimitedVoronoi()
      .x(function(d) { return this.xScale(d.value); }.bind(this))
      .y(function(d) { return this.yScale(d.rent); }.bind(this))
      .limit(50)
      .extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup = this.svg.append('g')
      .attr('class', 'voronoi');

    this.voronoiGroup.selectAll('path')
      .data(this.voronoi(this.data))
      .enter()
      .append('path')
      .style('fill', 'none')
      .attr('class', 'voronoiPath')
      .attr('d', function(d) { return d.path; })
      .style('pointer-events', 'all')
      .on('mousemove', this._mousemove.bind(this))
      .on('mouseout', this._mouseout.bind(this));

    // Attach hover circle
    this.svg.append('circle')
      .style('pointer-events', 'none')
      .attr('class', 'hover')
      .attr('fill', 'none')
      .attr('transform', 'translate(-100,-100)')
      .attr('r', this.isMobile ? 6 : 12);
  }

  _mousemove(d, i) {
    d3.select('.circle' + i).attr('stroke', 'none')

    d3.selectAll('.hover')
        .attr('stroke', '#111')
        .attr('stroke-width', 1.5)
        .attr('cx', this.xScale(d.datum.value))
        .attr('cy', this.yScale(d.datum.rent))
        .attr('transform', 'translate(0,0)');

    // // Fill the tooltip
    this.tooltip.html('<div class="tooltip-city">' + d.datum.municipality_name + '</div>' +
      '<table class="tooltip-table">' +
          '<tr class="first-row">' +
              '<td class="table-t">' + I18n.t('gobierto_common.visualizations.inhabitants') + '</td>' +
              '<td><span class="table-n">'+ accounting.formatNumber(d.datum.value, 0) +'</span></td>' +
          '</tr>' +
          '<tr class="second-row">' +
              '<td class="table-t">' + I18n.t('gobierto_common.visualizations.gross_income') + '</td>' +
              '<td>' + accounting.formatNumber(d.datum.rent, 0) + '€</td>' +
          '</tr>' +
      '</table>')
      .style('opacity', 1);

    // Tooltip position
    if (this.isMobile) {
      this.tooltip.style('opacity', 0);
    } else {
      var coords = d3.mouse(d3.select(this.container)._groups[0][0]);
      var x = coords[0], y = coords[1];

      this.tooltip.style('top', (y + 23) + 'px');

      if (x > 900) {
        // Move tooltip to the left side
        return this.tooltip.style('left', (x - 200) + 'px');
      } else {
        return this.tooltip.style('left', (x - 20) + 'px');
      }
    }
  }

  _mouseout(d, i) {
    d3.selectAll('.circle' + i).attr('stroke', 'white');

    d3.select('.hover')
        .attr('stroke', 'none');

    this.tooltip.style('opacity', 0);
  }

  _renderAxis() {
    // X axis
    this.svg.select('.x.axis')
      .attr('transform', 'translate(0,' + this.height + ')');

    this.xAxis
      .tickPadding(10)
      .ticks(3)
      .tickSize(-this.height)
      .scale(this.xScale)
      .tickFormat(this._formatNumberX.bind(this));

    this.svg.select('.x.axis').call(this.xAxis);

    // Y axis
    this.svg.select('.y.axis')
      .attr('transform', 'translate(' + this.width + ' ,0)');

    this.yAxis
      .scale(this.yScale)
      .ticks(this.isMobile ? 3 : 4)
      .tickSize(-this.width)
      .tickFormat(this._formatNumberY.bind(this));

    this.svg.select('.y.axis').call(this.yAxis);

    // Place y axis labels on top of ticks
    this.svg.selectAll('.y.axis .tick text')
      .attr('dx', '-3.4em')
      .attr('dy', '-0.55em');

    // Remove the zero on the y axis
    this.svg.selectAll('.y.axis .tick')
      .filter(function (d) { return d === 0;  })
      .remove();
  }

  _formatMillionAbbr(x) {
    return d3.format('.0f')(x / 1e6) + ' ' + I18n.t('gobierto_common.visualizations.million');
  }

  _formatThousandAbbr(x) {
    return d3.format('.0f')(x / 1e3) + ' ' + I18n.t('gobierto_common.visualizations.thousand');
  }

  _formatAbbreviation(x) {
    var v = Math.abs(x);

    return (v >= .9995e6 ? this._formatMillionAbbr : v >= .9995e4 ? this._formatThousandAbbr : this.formatThousand)(x);
  }

  _formatNumberX(d) {
    // Spanish custom thousand separator
    return this._formatAbbreviation(d);
  }

  _formatNumberY(d) {
    // Show percentages
    return accounting.formatNumber(d, 0) + '€';
  }

  _width() {
    return parseInt(d3.select(this.container).style('width'));
  }

  _height() {
    return this.isMobile ? 320 : this._width() * 0.5;
  }

  _resize() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + ' svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom);

    this.svg.select('.chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    this.svg.selectAll('.circles circle')
      .attr('cx', function(d) { return this.xScale(d.value); }.bind(this))
      .attr('cy', function(d) { return this.yScale(d.rent); }.bind(this));

    this.svg.select('.text-label text')
      .attr('x', function(d) { return this.xScale(d.value); }.bind(this))
      .attr('y', function(d) { return this.yScale(d.rent); }.bind(this));

    this.svg.selectAll('.rent-anno')
      .attr('x', this.width - 65);

    if (this.voronoi) {
      this.voronoi
        .extent([[0, 0], [this.width, this.height]]);

      this.voronoiGroup.selectAll('.voronoiPath')
        .data(this.voronoi(this.data))
        .attr("d", function(d) { return d.path; });
    }
  }

}
