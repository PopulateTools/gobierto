'use strict';

var VisLinesExecution = Class.extend({
  init: function(divId, type, category) {
    // Set default locale based on the app setting
    this.locale = I18n.locale;
    this.localeFallback = this.locale === 'en' ? 'es' : this.locale;

    d3.formatDefaultLocale(eval(this.locale));
    d3.timeFormatDefaultLocale(eval(this.locale));

    this.container = divId;
    this.data = null;
    this.executionKind = type;
    this.budgetCategory = category;
    this.placeId = d3.select('body').attr('data-place-id');
    this.parseTime = d3.timeParse('%Y-%m-%d');
    this.pctFormat = d3.format(',');
    this.monthFormat = d3.timeFormat('%B %Y');
    this.isMobile = window.innerWidth <= 768;
    this.selectionNode = d3.select(this.container).node();
    this.currentYear = new Date().getFullYear();
    this.budgetYear = d3.select('body').attr('data-year');

    this.t = d3.transition()
      .delay(function(d, i) { return i * 10;})
      .duration(1000);

    this.color = d3.scaleOrdinal()
      .domain(['I', 'G'])
      .range(['#f88f59', '#00909e']);

    // Create axes
    this.xAxis = d3.axisBottom();

    // Chart objects
    this.svg = null;
    this.chart = null;

    this.tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');

    d3.select(window).on('resize.' + this.container, this._resize.bind(this));
  },
  getData: function() {
    this.dataUrl = '/api/data/widget/budget_execution_comparison/' + this.placeId + '/' + this.budgetYear + '/' + this.executionKind + '/' + this.budgetCategory + '.json';

    d3.json(this.dataUrl, function(error, jsonData) {
      if (error) throw error;

      this.data = jsonData;
      this.updated = this.parseTime(this.data.last_update);

      // Setting scales in a separate step, as we need the lines to set the height
      this.setScales();
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
  setScales: function(callback) {
    // Chart dimensions
    this.margin = {top: 25, right: 0, bottom: 35, left: 385};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.x = d3.scaleLinear().range([0, this.width]);
    this.z = d3.scaleTime().range([0, this.width]);
    this.y0 = d3.scaleBand().padding(0.2);
    this.y1 = d3.scaleBand().rangeRound([this.height, 0]).paddingInner(0.1);

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
  },
  _sortHighest: function (target) {
    d3.select(target).classed('pure-button-active', true);
    d3.select('.sort-lowest-' + this.executionKind).classed('pure-button-active', false);

    this.nested.sort(function(a, b) { return a.group_pct - b.group_pct; });
    this.y0.domain(this.nested.map(function(d) { return d.key }))
      .rangeRound([this.y1.bandwidth(), 0]);

    this.y1.domain(_.flatten(this.nested.map(function(d) {
      return d.values.map(function(v) { return v.id }); })
    ));

    this.svg.selectAll('.line-group')
      .data(this.nested)
      .transition()
      .duration(500)
      .attr('transform', function(d) {
        return 'translate(' + 0 + ',' + this.y0(d.key) + ')';
      }.bind(this));

    this.svg.selectAll('.bar')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))

    this.svg.selectAll('.bar-bg')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))

    this.svg.selectAll('.line text')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))

    this.svg.selectAll('.hundred_percent')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y1', function(d) { return this.y1(d.id); }.bind(this))
      .attr('y2', function(d) { return this.y1(d.id) + this.y1.bandwidth() }.bind(this) )
  },
  _sortLowest: function(target) {
    d3.select(target).classed('pure-button-active', true);
    d3.select('.sort-highest-' + this.executionKind).classed('pure-button-active', false);

    // Sort by lowest execution
    this.nested.sort(function(a, b) { return b.group_pct - a.group_pct; });

    this.y1.domain(_.flatten(this.nested.map(function(d) {
      return d.values.map(function(v) { return v.id }); })
    ));

    this.y0.domain(this.nested.map(function(d) { return d.key }))
      .rangeRound([this.y1.bandwidth(), 0]);

    this.svg.selectAll('.line-group')
      .data(this.nested)
      .transition()
      .duration(500)
      .attr('transform', function(d) {
        return 'translate(' + 0 + ',' + (-this.y0(d.key) + this.margin.bottom) + ')';
      }.bind(this));

    this.svg.selectAll('.bar')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))

    this.svg.selectAll('.bar-bg')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))

    this.svg.selectAll('.line text')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))

    this.svg.selectAll('.hundred_percent')
      .transition()
      .delay(function(d, i) { return i * 20;})
      .duration(500)
      .attr('y1', function(d) { return this.y1(d.id); }.bind(this))
      .attr('y2', function(d) { return this.y1(d.id) + this.y1.bandwidth() }.bind(this) )
  },
  updateRender: function(callback) {
    d3.select('.last_update').text(this.monthFormat(this.updated));

    this.nested = d3.nest()
      .key(function(d) { return d.parent_id;})
      .sortValues(function(a, b) {
        // Parent lines are the first for each group, and then child lines are sorted by execution rate
        return a.level === 1 ? b.level - a.level : a.pct_executed - b.pct_executed;
      })
      .entries(this.data.lines);

    // Get parent line values for each group to sort them later
    this.nested.forEach(function(d) {
      d.group_pct = d.values.filter(function(d) { return d.level == 1;}).map(function(d) { return d.pct_executed;})[0];
      d.group_executed = d.values.filter(function(d) { return d.level == 1;}).map(function(d) { return d.executed;})[0];

      return d;
    });

    // Sort by execution
    this.nested.sort(function(a ,b) { return a.group_pct - b.group_pct;});

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

    this.bars = this.svg.selectAll('g')
      .data(this.nested)
      .enter()
      .append('g')
      .attr('class', 'line-group')
      .attr('transform', function(d) {
        return 'translate(' + 0 + ',' + this.y0(d.key) + ')';
      }.bind(this));

    var lineGroup = this.bars.selectAll('g')
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
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))
      .attr('width', function(d) { return this.x(d.pct_executed); }.bind(this))
      .attr('fill', function(d) {
        var levelTwoColor = d3.rgb(this.color(this.executionKind));
        levelTwoColor.opacity = 0.5;
        return d.level === 1 ? this.color(this.executionKind) : levelTwoColor;
      }.bind(this));

    /* Line names */
    lineGroup.append('text')
      .attr('x', 0)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this))
      .attr('dy', 18)
      .attr('dx', -10)
      .attr('text-anchor', 'end')
      .style('font-size', function(d) { return d.level === 1 ? '1rem' : '0.875rem';})
      .style('font-weight', function(d) { return d.level === 1 ? '600' : '400';})
      .style('fill', function(d) { return d.level === 1 ? '#4A4A4A' : '#767168';})
      .text(function(d) { return d['name_' + this.localeFallback] }.bind(this));

    /* Legend */
    var legend = this.svg.append('g')
      .attr('class', 'legend')
      .attr('transform', 'translate(0, -10)')

    legend.append('text')
      .attr('text-anchor', 'end')
      .attr('dx', '-12')
      .text(I18n.t('gobierto_budgets.budgets_execution.index.vis.lines_title'));

    legend.append('text')
      .attr('class', 'legend-value')
      .text(I18n.t('gobierto_budgets.budgets_execution.index.vis.percent'));

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

    $('#show-absolute-' + this.executionKind).on('change', function (e) {
      $('#show-absolute-' + this.executionKind).attr('data-checked', e.target.checked);
      this._update(e.target.checked);
    }.bind(this));

    // Trigger button updates
    $('.sort-highest-' + this.executionKind).on('click', function (e) {
      // var orderBy = eval(d3.select('#show-absolute-' + this.executionKind).attr('data-checked')) ? 'group_executed' : 'group_pct';
      this._sortHighest(e.target);
    }.bind(this));

    $('.sort-lowest-' + this.executionKind).on('click', function (e) {
      // var orderBy = eval(d3.select('#show-absolute-' + this.executionKind).attr('data-checked')) ? 'group_executed' : 'group_pct';
      this._sortLowest(e.target);
    }.bind(this));
  },
  _update: function(checked) {
    if (checked) {
      this.xAxis.tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d) + '€'}.bind(this))
      this.x.domain([0, d3.max(this.data.lines, function(d) { return d.executed;})]);

      this.svg.select('.x.axis')
        .call(this.xAxis);

      this.svg.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 0;})
        .remove();

      this.svg.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 100;})
        .classed('hundred_percent', true);

      this.svg.select('.legend-value')
        .text(I18n.t('gobierto_budgets.budgets_execution.index.vis.absolute'));

      this.svg.selectAll('.hundred_percent')
        .transition()
        .style('opacity', 0);

      this.svg.selectAll('.bar')
        .transition()
        .duration(300)
        .attr('width', function(d) { return this.x(d.executed); }.bind(this));
    } else {
      this.xAxis.tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d) + '%'}.bind(this))
      this.x.domain([0, d3.max(this.data.lines, function(d) { return d.pct_executed;})]);

      this.svg.select('.x.axis')
        .call(this.xAxis);

      this.svg.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 0;})
        .remove();

      this.svg.selectAll('.x.axis .tick')
        .filter(function(d) { return d === 100;})
        .classed('hundred_percent', true);

      this.svg.select('.legend-value')
        .text(I18n.t('gobierto_budgets.budgets_execution.index.vis.percent'));

      this.svg.selectAll('.hundred_percent')
        .transition()
        .style('opacity', 1);

      this.svg.selectAll('.bar')
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
      .style('top', (y + 40) + 'px');

    this.tooltip.html('<div class="line-name"><strong>' + d['name_' + this.localeFallback] + '</strong></div> \
                       <div class="line-name">' + accounting.formatMoney(d.budget, "€", 0, ".", ",") + '</div> \
                       <div>' + I18n.t('gobierto_budgets.budgets_execution.index.vis.tooltip') + ' ' + this.pctFormat(d.pct_executed) + '%</div>');
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
    // Height depends on line number
    return this.isMobile ? 200 : this.data.lines.length * 33;
  },
  _resize: function() {

  }
});
