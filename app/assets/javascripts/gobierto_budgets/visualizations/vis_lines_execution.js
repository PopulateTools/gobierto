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
    this.dayFormat = d3.timeFormat('%e %B %Y');
    this.isMobile = window.innerWidth <= 768;
    this.selectionNode = d3.select(this.container).node();
    this.currentYear = new Date().getFullYear();
    this.budgetYear = d3.select('body').attr('data-year');

    // Income and expenses colors
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
  },
  getData: function() {
    this.dataUrl = '/presupuestos/api/data/widget/budget_execution_comparison/' + this.placeId + '/' + this.budgetYear + '/' + this.executionKind + '/' + this.budgetCategory + '.json';

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
    this.margin = {top: 55, right: 0, bottom: 50, left: this.isMobile ? 0 : 385};
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    this.maxPct = d3.max(this.data.lines, function(d) { return d.pct_executed;});

    // Triggered if a budget line's execution is over 500%
    this.bigDeviation = this.maxPct > 500;

    // Scales & Ranges
    this.x = this.bigDeviation ? d3.scaleLog().range([0.1, this.width]) : d3.scaleLinear().range([0, this.width]).clamp(true);
    this.z = d3.scaleTime().range([0, this.width]);
    this.y0 = d3.scaleBand().rangeRound([this.height, 0]).paddingInner(0.5);
    this.y1 = d3.scaleBand().rangeRound([this.height, 0]).paddingInner(0.5).paddingOuter(0);

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
      .ticks(this.isMobile ? 2 : this.bigDeviation ? 3 : 5);

    // Message if custom lines are empty
    if (this.data.lines.length === 0) {
      d3.select(this.container).append('div')
        .attr('class', 'flash-message alert')
        .text(I18n.t('gobierto_budgets.budgets_execution.index.vis.empty_lines'));
    }
  },
  updateRender: function(callback) {
    this.nested = d3.nest()
      .key(function(d) { return d.parent_id;})
      .sortValues(function(a, b) {
        // Parent lines are the first for each group, and then child lines are sorted by execution rate
        return a.level === 1 || b.level === 1 ? b.level - a.level : b.id - a.id;
      })
      .entries(this.data.lines);

    // Get parent line values for each group to sort them later
    this.nested.forEach(function(d) {
      d.group_pct = d.values.filter(function(d) { return d.level == 1;}).map(function(d) { return d.pct_executed;})[0];
      d.group_executed = d.values.filter(function(d) { return d.level == 1;}).map(function(d) { return d.executed;})[0];

      return d;
    });

    if (this.data.lines.length === 0)
      return false;

    // Sort by execution
    this.nested.sort(function(a ,b) { return a.group_pct - b.group_pct;});

    /* Extent of the execution */
    this.x.domain(this.maxPct <= 100 ? [0.1, 100] : [0.1, this.maxPct]);

    /* Number of lines */
    this.y0.domain(this.nested.map(function(d) { return d.key }));

    /* Get the id of every line */
    this.y1.domain(_.flatten(this.nested.map(function(d) {
      return d.values.map(function(v) { return v.id }); })
    ));

    /* A time scale which spreads along the whole chart */
    this.z.domain([this.parseTime(this.currentYear + '-01-01'), this.parseTime(this.currentYear + '-12-31')]);

    this.bars = this.svg.selectAll('g')
      .data(this.nested)
      .enter()
      .append('g')
      .attr('class', 'line-group')
      .attr('transform', function(d, i) {
        return 'translate(' + 0 + ',' + this.y0(d.key) / 14 + ')';
      }.bind(this));

    var lineGroup = this.bars.selectAll('a')
      .data(function(d) { return d.values;} )
      .enter()
      .append('a')
      .attr('class', 'line')
      .attr('xlink:href', function(d) {
        return '/presupuestos/partidas/' + d.id + '/' + this.budgetYear + '/' + this.budgetCategory + '/' + this.executionKind;
      }.bind(this))
      .attr('target', '_top');

    var barGroup = lineGroup.append('g')
      .attr('class', 'bar-group')
      .on('mousemove', this._mousemoved.bind(this))
      .on('mouseleave', this._mouseleft.bind(this));

    barGroup.append('rect')
      .attr('class', 'bar-bg')
      .attr('x', 0)
      .attr('height', this.y1.bandwidth() )
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
        levelTwoColor.opacity = this.isMobile ? 0.3 : 0.5;

        return d.level === 1 ? this.color(this.executionKind) : levelTwoColor;
      }.bind(this));

    /* Line names */
    if (!this.isMobile) {
      lineGroup
        .append('text')
        .attr('x', 0)
        .attr('y', function(d) { return this.y1(d.id); }.bind(this))
        .attr('dy', 12)
        .attr('dx', -10)
        .attr('text-anchor', 'end')
        .style('font-size', function(d) { return d.level === 1 ? '1rem' : '0.875rem';})
        .style('font-weight', function(d) { return d.level === 1 ? '600' : '400';})
        .style('fill', function(d) { return d.level === 1 ? '#4A4A4A' : '#767168';})
        .text(function(d) { return d['name_' + this.localeFallback] }.bind(this))
        .on('mousemove', function () {
          $(this).prev().css('stroke', 'black');
        })
        .on('mouseleave', function () {
          $(this).prev().css('stroke', 'none');
        })
        .append('title')
        .text(function(d) { return d['name_' + this.localeFallback] }.bind(this));
    } else {
      lineGroup
        .append('text')
        .attr('x', 0)
        .attr('y', function(d) { return this.y1(d.id); }.bind(this))
        .attr('dy', 12)
        .attr('dx', 2)
        .attr('text-anchor', 'start')
        .style('text-shadow', function(d) { return d.level === 1 ? '0 0 4px white' : '';})
        .style('font-size', function(d) { return d.level === 1 ? '0.875rem' : '0.75rem';})
        .style('font-weight', function(d) { return d.level === 1 ? '600' : '400';})
        .style('fill', '#4A4A4A')
        .text(function(d) { return d['name_' + this.localeFallback] }.bind(this))
        .style('pointer-events', 'none');
    }

    this.svg.append('g')
      .attr('class', 'x axis')
    	.call(this.xAxis);

    /* Legend */
    var legend = this.svg.append('g')
      .attr('class', 'legend')
      .attr('transform', 'translate(0, -10)')

    if (!this.isMobile) {
      legend.append('text')
        .attr('text-anchor', 'end')
        .attr('dx', '-12')
        .text(I18n.t('gobierto_budgets.budgets_execution.index.vis.lines_title'));
    }

    legend.append('text')
      .attr('class', 'legend-value halo')
      .text(this.bigDeviation ? I18n.t('gobierto_budgets.budgets_execution.index.vis.percent_log') : I18n.t('gobierto_budgets.budgets_execution.index.vis.percent'))
      .attr('stroke', 'white')
      .attr('stroke-width', 5);

    legend.append('text')
      .attr('class', 'legend-value')
      .text(this.bigDeviation ? I18n.t('gobierto_budgets.budgets_execution.index.vis.percent_log') : I18n.t('gobierto_budgets.budgets_execution.index.vis.percent'));

    /* Year progress line */
    if (this.budgetYear == this.currentYear) {
      var yearProgress = this.svg.append('g')
        .attr('class', 'year_progress')
        .attr('transform', 'translate(' + this.z(this.updated) + ',' + 0 + ')');

      var yearArrow = yearProgress.append('g')
        .attr('class', 'swoopy_arrow desktop_only')
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

      // Tooltip group
      var hovered = yearProgress.append('g')
        .attr('class', 'tooltiped')
        .attr('original-title', I18n.t('gobierto_budgets.budgets_execution.index.tooltip_disclaimer'))
        .style('cursor', 'pointer');

      hovered.append('text')
        .attr('class', 'legend-text')
        .attr('dx', this.isMobile ? 0 : 25)
        .attr('dy', this.isMobile ? -25 : -38)
        .attr('text-anchor', function() {
          // If on a phone, adjust the alignment when we are closer to the end of the year
          if (this.isMobile) {
            return this.updated >= this.parseTime(this.currentYear + '-10-01') ? 'end' : 'middle';
          }
        }.bind(this))
        .text(this.monthFormat(this.updated));

      // Info icon
      var info = hovered.append('g')
        .attr('fill-rule', 'evenodd')
        .attr('transform', function() {
          var labelWidth = d3.select('.legend-text').node().getBoundingClientRect().width;

          if (this.isMobile) {
            return this.updated >= this.parseTime(this.currentYear + '-10-01') ? 'translate(' + (labelWidth - 58) + ',' + -36 + ')' : 'translate(' + (labelWidth - 26) + ',' + -36 + ')';
          } else {
            return 'translate(' + (labelWidth + 30) + ',' + -50 + ')';
          }
        }.bind(this));

      info.append('path')
        .attr('fill', '#00909E')
        .attr('d', 'M8.5 9.7V8.5s0-.3-.2-.3h-.8v-4s0-.2-.2-.2H4.8c-.2 0-.3 0-.3.2v1.3s0 .2.3.2h.7v2.5h-.7c-.2 0-.3.2-.3.3v1.2c0 .2 0 .3.3.3h3.5s.2 0 .2-.3zm-1-7V1.5s0-.3-.2-.3H5.8c-.2 0-.3.2-.3.3v1.2c0 .2 0 .3.3.3h1.5s.2 0 .2-.3zm5 3.3c0 3.3-2.7 6-6 6s-6-2.7-6-6 2.7-6 6-6 6 2.7 6 6z');

      info.append('path')
        .attr('fill', '#fff')
        .attr('d', 'M7.3 3H5.7s-.2 0-.2-.2V1.4s0-.2.2-.2h1.6s.2 0 .2.2v1.4s0 .2-.2.2zM7.3 5.7H4.7s-.2 0-.2-.2V4.2s0-.2.2-.2h2.6s.2 0 .2.2v1.3s0 .2-.2.2z');

      info.append('path')
        .attr('fill', '#fff')
        .attr('d', 'M5.7 10h1.6s.2 0 .2-.2V5.6s0-.2-.2-.2H5.7s-.2 0-.2.2v4.2s0 .2.2.2z');

      info.append('path')
        .attr('fill', '#fff')
        .attr('d', 'M8.6 9.8V8.4s0-.2-.2-.2H4.7s-.2 0-.2.2v1.4s0 .2.2.2h3.7s.2 0 .2-.2');
    }

    /* Remove first tick */
    d3.selectAll('.x.axis .tick')
      .filter(function(d) { return d === 0 || d === 0.1;})
      .remove();

    /* Style 100% completion */
    d3.selectAll('.x.axis .tick')
      .filter(function(d) { return d === 100;})
      .classed('hundred_percent', true);

    /* Switch to absolute values */
    $('.value-switcher-' + this.executionKind).on('click', function (e) {
      var valueKind = $(e.target).attr('data-toggle');
      var symbol = $(e.target).attr('data-symbol');

      $('.value-switcher-' + this.executionKind).removeClass('active');
      $(e.target).addClass('active');

      this._update(valueKind, symbol);
    }.bind(this));

    /* Trigger sorting functions */
    $('.sort-' + this.executionKind).on('click', function (e) {
      var sortKind = $(e.target).attr('data-toggle');

      $('.sort-' + this.executionKind).removeClass('active');
      $(e.target).addClass('active');

      this._sortValues(e.target, sortKind);
    }.bind(this));

    d3.select('body:not(' + this.container +')').on('touchstart', this._mouseleft.bind(this));
  },
  _update: function(valueKind, symbol) {
    this.xAxis.tickFormat(function(d) { return d === 0 ? '' : this.pctFormat(d) + symbol}.bind(this));
    this.x.domain([0.1, d3.max(this.data.lines, function(d) { return d[valueKind];})]);

    this.svg.select('.x.axis')
      .call(this.xAxis);

    this.svg.selectAll('.x.axis .tick')
      .filter(function(d) { return valueKind === 'executed' ? d === 0 || d === 0.1 || d === 1 : d === 0 || d === 0.1;})
      .remove();

    this.svg.selectAll('.x.axis .tick')
      .filter(function(d) { return d === 100;})
      .classed('hundred_percent', valueKind === 'pct_executed' ? true : false);

    this.svg.select('.legend-value')
      .text(valueKind === 'executed' ? I18n.t('gobierto_budgets.budgets_execution.index.vis.absolute') : I18n.t('gobierto_budgets.budgets_execution.index.vis.percent'));

    this.svg.selectAll('.hundred_percent')
      .transition()
      .style('opacity', valueKind === 'executed' ? 0 : 1);

    this.svg.selectAll('.bar')
      .transition()
      .duration(300)
      .attr('width', function(d) { return this.x(d[valueKind]); }.bind(this));
  },
  _sortValues: function (target, sortKind) {
    sortKind === 'highest' ? this.nested.sort(function(a, b) { return a.group_pct - b.group_pct; }) : this.nested.sort(function(a, b) { return b.group_pct - a.group_pct; })

    this.y0.domain(sortKind === 'highest' ?  this.nested.map(function(d) { return d.key; }) : this.nested.map(function(d) { return d.key; }).reverse());

    this.y1.domain(_.flatten(this.nested.map(function(d) {
      return d.values.map(function(v) { return v.id }); })
    ));

    this.svg.selectAll('.line-group')
      .data(this.nested)
      .transition()
      .duration(500)
      .attr('transform', function(d) {
        return 'translate(' + 0 + ',' + this.y0(d.key) / 14 + ')';
      }.bind(this));

    this.svg.selectAll('.bar')
      .transition()
      .duration(300)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this));

    this.svg.selectAll('.bar-bg')
      .transition()
      .duration(300)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this));

    this.svg.selectAll('.line text')
      .transition()
      .duration(300)
      .attr('y', function(d) { return this.y1(d.id); }.bind(this));

    this.svg.selectAll('.hundred_percent')
      .transition()
      .duration(300)
      .attr('y1', function(d) { return this.y1(d.id); }.bind(this))
      .attr('y2', function(d) { return this.y1(d.id) + this.y1.bandwidth() }.bind(this) );
  },
  _mousemoved: function(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0], y = coordinates[1];

    this.tooltip
      .style('display', 'block')
      .style('left', (x - 110) + 'px')
      .style('top', (y + 40) + 'px');

    this.tooltip.html('<div class="line-name"><strong>' + d['name_' + this.localeFallback] + '</strong></div> \
                       <div class="line-name">' + I18n.t('gobierto_budgets.budgets_execution.index.vis.tooltip_budgeted')  + ': ' + accounting.formatMoney(d.budget, "€", 0, ".", ",") + '</div> \
                       <div>' + I18n.t('gobierto_budgets.budgets_execution.index.vis.tooltip') + ' ' + this.pctFormat(d.pct_executed) + '%</div>');
  },
  _mouseleft: function(d) {
    d3.selectAll('.tooltip').style('display', 'none');
  },
  _width: function() {
    return parseInt(d3.select(this.container).style('width'));
  },
  _height: function() {
    // Height depends on number of lines
    var groupPadding = this.data.lines.filter(function (d) { return d.level === 1}).length * 10;

    return (this.data.lines.length * 30) + groupPadding;
  },
});
