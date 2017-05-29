'use strict';

var VisBubbles = Class.extend({
  init: function(divId, budgetCategory, data) {
    this.container = divId;
    this.currentYear = parseInt(d3.select('body').attr('data-year'));
    this.data = data;
    this.budget_category = budgetCategory;
    this.forceStrength = 0.045;

    this.margin = {top: 20, right: 10, bottom: 20, left: 10},
    this.width = parseInt(d3.select(this.container).style('width')) - this.margin.left - this.margin.right;
    this.height = 520 - this.margin.top - this.margin.bottom;
    this.center = { x: this.width / 2, y: this.height / 2 };

    this.selectionNode = d3.select(this.container)._groups[0][0];

    this.tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');

    this.nodes = [];

    this.simulation = d3.forceSimulation()
      .velocityDecay(0.2)
      .force('x', d3.forceX().strength(this.forceStrength).x(this.center.x))
      .force('y', d3.forceY().strength(this.forceStrength).y(this.center.y))
      .force('charge', d3.forceManyBody().strength(this._charge))
      .on('tick', this._ticked.bind(this));

    this.simulation.stop();

    this.svg = d3.select(this.container).append('svg')
      .attr('width', this.width + this.margin.left + this.margin.right)
      .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append('g')
      .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');
  },
  render: function() {
    this.updateRender();
  },
  createNodes: function(rawData, year) {
    var data = rawData;

    this.filtered = data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));
    this.maxAmount = d3.max(this.filtered, function (d) { return d.values[year] }.bind(this));

    this.radiusScale = d3.scalePow()
      .exponent(0.5)
      .range([2, 90])
      .domain([0, this.maxAmount]);

    this.nodes = this.filtered.map(function (d) {
      return {
        id: +d.id,
        radius: this.radiusScale(d.values[year]),
        value: d.values[year],
        group: d.level_1,
        name: d.level_2,
        pct_diff: d.pct_diff[year],
        per_inhabitant: d.values_per_inhabitant[year],
        x: Math.random() * 900,
        y: Math.random() * 1000,
        year: d3.keys(d.values).filter(function(d) { return d == year })
      };
    }.bind(this)).filter(function(d) { return d.value > 0 });

    this.nodes.sort(function (a, b) { return b.value - a.value; });

    return this.nodes;
  },
  update: function(year) {
    this.nodes = this.createNodes(this.data, year);

    console.log(this.nodes);

    this.svg.selectAll('.bubble-g')
      .data(this.nodes, function (d) { return d.id; })

    this.svg.selectAll('.bubble-g')
      .exit().remove()

    var updatedBubbles = this.svg.selectAll('.bubble')
      .attr('class', function(d) { return d.year + ' bubble'})
      .attr('r', function (d) { return d.radius; })
      .on('mousemove', this._mousemoved.bind(this))
      .on('mouseleave', this._mouseleft.bind(this));

    this.bubbles = this.bubbles.merge(updatedBubbles);

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
    this.simulation.stop();
  },
  updateRender: function(callback) {
    var budgetCategory = this.budget_category;
    this.nodes = this.createNodes(this.data, this.currentYear)

    this.budgetColor = d3.scaleOrdinal()
      .domain(['income', 'expense'])
      .range(['#d9eef1', '#fab395']);

    this.bubbles = this.svg.selectAll('g')
      .data(this.nodes, function (d) { return d.id; })
      .enter()
      .append('g')
      .attr('class', 'bubble-g')

    var bubblesG = this.bubbles.append('circle')
      .attr('class', function(d) { return d.year + ' bubble'})
      .attr('r', function (d) { return d.radius; })
      .attr('fill', this.budgetColor(this.budget_category))
      .attr('stroke', d3.rgb(this.budgetColor(this.budget_category)).darker())
      .attr('stroke-width', 2)
      .on('mousemove', this._mousemoved.bind(this))
      .on('mouseleave', this._mouseleft.bind(this));

    this.bubbles = this.bubbles.merge(bubblesG);

    this.bubbles.append('text')
      .attr('text-anchor', 'middle')
      .tspans(function(d) { return d.radius > 50 ? d3.wordwrap(d.name, 15) : d3.wordwrap('', 15) });

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
  },
  _ticked: function() {
    this.bubbles.attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')' })
  },
  _mousemoved: function(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0], y = coordinates[1];

    this.tooltip
      .style('display', 'block')
      .style('left', (x - 50) + 'px')
      .style('top', (y + 40) + 'px')

    this.tooltip.html('<div>' + d.name + '</div><div>(' + d.year + ') ' + d.pct_diff + '</div>');
  },
  _mouseleft: function() {
    this.tooltip.style('display', 'none');
  },
  _charge: function(d) {
    return -Math.pow(d.radius, 2) * 0.055;
  }.bind(this)
});
