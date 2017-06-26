'use strict';

var VisLinesExecution = Class.extend({
  init: function(divId) {
    this.container = divId;
    this.data = null;
    this.parseTime = d3.timeParse('%Y-%m-%d');
    this.pctFormat = d3.format('.0%');
    this.isMobile = window.innerWidth <= 768;
    this.selectionNode = d3.select(this.container).node();

    // Set default locale based on the app setting
    d3.formatDefaultLocale(eval(I18n.locale));
    d3.timeFormatDefaultLocale(eval(I18n.locale));

    // Chart dimensions
    this.margin = {top: 25, right: 50, bottom: 35, left: 385};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.x = d3.scaleLinear().range([0, this.width]);
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
      .tickSize(-this.height - this.margin.bottom)
      .ticks(4)
      .tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d);}.bind(this));

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
    this.x.domain([0, 1.15])

    this.updated = this.parseTime(this.data.last_update);
    d3.select('.last_update').text(d3.timeFormat('%B %Y')(this.updated));

    /* Flatten array to transform it easily */
    this.flattened = _.flatMapDeep(this.data.lines, function(n) { return [n, n.child_lines]; });

    this.nested = d3.nest()
      .key(function(d) { return d.cat_id;})
      .sortValues(function(a, b) {
        // If it's from the first level make it the first one, then sort by execution
        return a.level === 1 ? b.level - a.level : a.pct_executed - b.pct_executed
      })
      .entries(this.flattened)

    /* Get the name of every line */
    this.y1.domain(_.flatten(this.nested.map(function(d) {
      return d.values.map(function(v) { return v.id }); })
    ));

    /* Number of lines */
    this.y0.domain(this.nested.map(function(d) { return d.key }))
      .rangeRound([this.y1.bandwidth(), 0]);

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
      .attr('width', this.x(1.15))
      .attr('fill', '#efefef');

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
      .attr('dy', 28)
      .attr('dx', -10)
      .attr('text-anchor', 'end')
      .style('font-size', function(d) { return d.level === 1 ? '1rem' : '0.875rem';})
      .style('font-weight', function(d) { return d.level === 1 ? '600' : '400';})
      .style('fill', function(d) { return d.level === 1 ? '#4A4A4A' : '#767168';})
      .text(function(d) { return d.name;})

    this.svg.append('g')
      .attr('class', 'x axis')
    	.call(this.xAxis)

    /* Remove first tick */
    d3.selectAll('.x.axis .tick')
      .filter(function(d) { return d === 0;})
      .remove()
  },
  _mousemoved: function(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0], y = coordinates[1];

    this.tooltip
      .style('display', 'block')
      .style('left', (x - 80) + 'px')
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
    return this.isMobile ? 200 : this._width() * 0.5;
  },
  _resize: function() {

  }
});
