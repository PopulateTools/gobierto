'use strict';

var VisLinesExecution = Class.extend({
  init: function(divId) {
    // Set default locale based on the app setting
    this.locale = I18n.locale;
    d3.formatDefaultLocale(eval(this.locale));
    d3.timeFormatDefaultLocale(eval(this.locale));

    this.container = divId;
    this.data = null;
    this.placeId = d3.select('body').attr('data-place-id');
    this.parseTime = d3.timeParse('%Y-%m-%d');
    this.pctFormat = d3.format(',');
    this.monthFormat = d3.timeFormat('%B %Y');
    this.isMobile = window.innerWidth <= 768;
    this.selectionNode = d3.select(this.container).node();
    this.currentYear = new Date().getFullYear();
    this.budgetYear = d3.select('body').attr('data-year');

    // Chart dimensions
    this.margin = {top: 25, right: 50, bottom: 35, left: 385};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.x = d3.scaleLinear().range([0, this.width]);
    this.z = d3.scaleTime().range([0, this.width]);
    this.y0 = d3.scaleBand().padding(0.2);
    this.y1 = d3.scaleBand().rangeRound([this.height, 0]).paddingInner(0.1);

    this.color = d3.scaleOrdinal();

    // Create axes
    this.xAxis = d3.axisBottom();

    // Chart objects
    this.svg = null;
    this.chart = null;

    this.tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');

    // Create main elements
    this.svg = d3.select(this.container)
      .append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('class', 'chart-container')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');

    this.xAxis = d3.axisTop(this.x)
      .tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d) + '%'}.bind(this))
      .tickSize(-this.height - this.margin.bottom)
      .tickPadding(10)
      .ticks(5);

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    d3.json('/api/data/widget/budget_execution_comparison/' + this.placeId + '/' + this.budgetYear + '/G/functional.json', function(error, jsonData) {
      if (error) throw error;

      this.data = jsonData;
      this.updated = this.parseTime(this.data.last_update);
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
    d3.select('.last_update').text(this.monthFormat(this.updated));

    this.nested = d3.nest()
      .key(function(d) { return d.parent_id;})
      .sortValues(function(a, b) {
        // If it's from the first level make it the first one, then sort by execution
        return a.level === 1 ? b.level - a.level : a.pct_executed - b.pct_executed
      })
      .entries(this.data.lines)

    /* Extent of the execution */
    this.x.domain([0, d3.max(this.data.lines, function(d) { return d.pct_executed;})]);

    /* Get the id of every line */
    this.y1.domain(_.flatten(this.nested.map(function(d) {
      return d.values.map(function(v) { return v.id }); })
    ));

    /* Number of lines */
    this.y0.domain(this.nested.map(function(d) { return d.key }))
      .rangeRound([this.y1.bandwidth(), 0]);

    /* A time scale which spreads along the whole chart */
    this.z.domain([this.parseTime(this.currentYear + '-01-01'), this.parseTime(this.currentYear + '-12-31')]);

    var bars = this.svg.selectAll('g')
      .data(this.nested)
      .enter()
      .append('g')
      .attr('class', 'line-group')
      .attr('transform', function(d) {
        return 'translate(' + 0 + ',' + this.y0(d.key) + ')';
      }.bind(this));

    var lineGroup = bars.selectAll('g')
      .data(function(d) { return d.values;} )
      .enter()
      .append('g')
      .attr('class', 'line');

    var barGroup = lineGroup.append('g')
      .attr('class', 'bar-group')
      .on('mousemove', this._mousemoved.bind(this))
      .on('mouseleave', this._mouseleft.bind(this));

    barGroup.append('rect')
      .attr('class', 'bar-bg')
      .attr('x', 0)
      .attr('height', this.y1.bandwidth() )
      // .attr('height', function(d) { return d.level === 1 ? this.y1.bandwidth() : 30 ;}.bind(this))
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))
      .attr('width', this.x(this.x.domain()[1]))
      .attr('fill', '#efefef');

    /* White bar marking 100% completion */
    barGroup.append('line')
      .attr('class', 'hundred_percent')
      .attr('x1', this.x(100))
      .attr('x2', this.x(100))
      .attr('y1', function(d) { return this.y1(d.id); }.bind(this))
      .attr('y2', function(d) { return this.y1(d.id) + this.y1.bandwidth() }.bind(this) )
      .attr('stroke', 'white')
      .attr('stroke-width', 4)

    /* Main bar */
    barGroup.append('rect')
      .attr('class', 'bar')
      .attr('x', 0)
      .attr('height', this.y1.bandwidth() )
      // .attr('height', function(d) { return d.level === 1 ? this.y1.bandwidth() : 30 ;}.bind(this))
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))
      .attr('width', function(d) { return this.x(d.pct_executed); }.bind(this))
      .attr('fill', function(d) {
        return d.level === 1 ? '#00909e' : '#9bcdd2'
      });

    lineGroup.append('text')
      .attr('x', 0)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))
      .attr('dy', 16)
      .attr('dx', -10)
      .attr('text-anchor', 'end')
      .style('font-size', function(d) { return d.level === 1 ? '1rem' : '0.875rem';})
      .style('font-weight', function(d) { return d.level === 1 ? '600' : '400';})
      .style('fill', function(d) { return d.level === 1 ? '#4A4A4A' : '#767168';})
      .text(function(d) { return this.locale !== 'en' ? d['name_' + this.locale]: d.name_es }.bind(this));

    /* Legend */
    var legend = this.svg.append('g')
      .attr('class', 'legend')
      .attr('transform', 'translate(0, -10)')

    legend.append('text')
      .attr('text-anchor', 'end')
      .attr('dx', '-12')
      .text('Partidas presupuestarias');

    legend.append('text')
      .attr('class', 'legend-value')
      .text('% de progreso');

    /* Year progress line */
    // if (this.budgetYear === this.currentYear) {
      var yearProgress = this.svg.append('g')
        .attr('class', 'year_progress')
        .attr('transform', 'translate(' + this.z(this.updated) + ',' + 0 + ')');

      var yearArrow = yearProgress.append('g')
        .attr('class', 'swoopy_arrow')
        .attr('fill', 'none')
        .attr('transform', 'translate(-5, -40)');

      yearArrow.append('path')
        .attr('stroke', '#979797')
        .attr('d', 'M6.12890625,30.7975072 C6.12890625,13.9746951 12.1289062,4.02519777 24.1289062,0.949015299');

      yearArrow.append('polygon')
        .attr('fill', '#979797')
        .attr('points', '8.366 24.01 10.271 32.463 2.518 29.857')
        .attr('transform', 'rotate(45 6.395 28.236)');

      yearProgress.append('line')
        .attr('y2', this.height + this.margin.bottom)
        .attr('stroke', 'black');

      yearProgress.append('text')
      .attr('dy', -40)
      .attr('dx', 25)
      .text(this.monthFormat(this.updated));
    // }

    this.svg.append('g')
      .attr('class', 'x axis')
    	.call(this.xAxis);

    /* Remove first tick */
    d3.selectAll('.x.axis .tick')
      .filter(function(d) { return d === 0;})
      .remove();

    /* Style 100% completion */
    d3.selectAll('.x.axis .tick')
      .filter(function(d) { return d === 100;})
      .classed('hundred_percent', true);

    $('#show-absolute').on('change', function (e) {
      this._update(e.target.checked);
    }.bind(this))
  },
  _update: function(checked) {
    if (checked) {
      this.xAxis.tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d) + '€'}.bind(this))
      this.x.domain([0, d3.max(this.data.lines, function(d) { return d.executed;})]);

      d3.select('.x.axis')
        .call(this.xAxis);

      d3.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 0;})
        .remove();

      d3.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 100;})
        .classed('hundred_percent', true);

      d3.select('.legend-value')
        .text('Valores absolutos (€)');

      d3.selectAll('.hundred_percent')
        .transition()
        .style('opacity', 0);

      d3.selectAll('.bar')
        .transition()
        .duration(300)
        .attr('width', function(d) { return this.x(d.executed); }.bind(this));
    } else {
      this.xAxis.tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d) + '%'}.bind(this))
      this.x.domain([0, d3.max(this.data.lines, function(d) { return d.pct_executed;})]);

      d3.select('.x.axis')
        .call(this.xAxis);

      d3.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 0;})
        .remove();

      d3.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 100;})
        .classed('hundred_percent', true);

      d3.select('.legend-value')
        .text('% de progreso');

      d3.selectAll('.hundred_percent')
        .transition()
        .style('opacity', 1);

      d3.selectAll('.bar')
        .transition()
        .duration(300)
        .attr('width', function(d) { return this.x(d.pct_executed); }.bind(this));
    }
  },
  _mousemoved: function(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0], y = coordinates[1];

    this.tooltip
      .style('display', 'block')
      .style('left', (x - 110) + 'px')
      .style('top', (y + 40) + 'px')

    this.tooltip.html('<div class="line-name"><strong>' + accounting.formatMoney(d.budget, "€", 0, ".", ",") + '</strong></div> \
                       <div>Se ha ejecutado un ' + this.pctFormat(d.pct_executed) + '</div>');
  },
  _mouseleft: function(d) {
    this.tooltip.style('display', 'none');
  },
  _renderAxis: function() {

  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    return this.isMobile ? 200 : this._width() * 0.6;
  },
  _resize: function() {

  }
});
