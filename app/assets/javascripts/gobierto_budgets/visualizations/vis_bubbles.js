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

    this.selectionNode = d3.select(this.container).node();

    this.tooltip = d3.select(this.container)
      .append('div')
      .attr('class', 'tooltip');

    this.nodes = [];

    this.simulation = d3.forceSimulation()
      .velocityDecay(0.3)
      .force('x', d3.forceX().strength(this.forceStrength).x(this.center.x))
      .force('y', d3.forceY().strength(this.forceStrength).y(this.center.y))
      .force('charge', d3.forceManyBody().strength(this._charge))
      .force("collide", d3.forceCollide().radius(function(d) { return d.radius + 0.5; }).iterations(2))
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

    this.maxAmount = d3.max(data, function (d) { return d.values[year] }.bind(this));
    this.filtered = data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));

    this.radiusScale = d3.scaleSqrt()
      .range([0, 120])
      .domain([0, this.maxAmount]);

    if (this.nodes.length > 0) {
      this.nodes.forEach(function(d) {
        d.radius = this.radiusScale(d.values[year])
        d.value = d.values[year]
        d.pct_diff = d.pct_diffs[year]
        d.per_inhabitant = d.values_per_inhabitant[year]
        d.year = year
      }.bind(this))
    } else {
      this.nodes = this.filtered.map(function (d) {
        return {
          values: d.values,
          pct_diffs: d.pct_diff,
          values_per_inhabitant: d.values_per_inhabitant,
          id: +d.id,
          radius: this.radiusScale(d.values[year]),
          value: d.values[year],
          group: d.level_1,
          name: d.level_2,
          pct_diff: d.pct_diff[year],
          per_inhabitant: d.values_per_inhabitant[year],
          x: Math.random() * 600,
          y: Math.random() * 500,
          year: year
        };
      }.bind(this))
    }

    this.nodes.sort(function (a, b) { return b.value - a.value; });

    return this.nodes;
  },
  update: function(year) {
    var t = d3.transition()
      .duration(750);

    this.nodes = this.createNodes(this.data, year);
    this.bubbles.data(this.nodes, function (d) { return d.name; })

    d3.selectAll('.bubble')
      .data(this.nodes, function (d) { return d.name; })
      .attr('class', function(d) { return 'bubble bubble-' + d.year})
      .transition(t)
      .attr('r', function (d) { return d.radius; })
      .attr('fill', function(d) { return this.budgetColor(d.pct_diff)}.bind(this))

    this.simulation
      .nodes(this.nodes)

    this.simulation.alpha(1).restart();
  },
  updateRender: function(callback) {
    var budgetCategory = this.budget_category;
    this.nodes = this.createNodes(this.data, this.currentYear)

    this.budgetColor = d3.scaleThreshold()
      .domain([-50, -20, 10, 0, 10, 20, 50])
      .range(['#b2182b','#d6604d','#f4a582','#fddbc7','#d1e5f0','#92c5de','#4393c3','#2166ac'])

    this.bubbles = this.svg.selectAll('g')
      .data(this.nodes, function (d) { return d.name; })
      .enter()
      .append('g')
      .attr('class', 'bubble-g')

    var bubblesG = this.bubbles.append('circle')
      .attr('class', function(d) { return d.year + ' bubble'})
      .attr('r', function (d) { return d.radius; })
      .attr('fill', function(d) { return this.budgetColor(d.pct_diff)}.bind(this))
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

    this.tooltip.html('<div>' + d.name + '</div><div>' + d.year + ': ' + d3.format('+')(d.pct_diff) + '%</div>');
  },
  _mouseleft: function() {
    this.tooltip.style('display', 'none');
  },
  _charge: function(d) {
    return -Math.pow(d.radius, 2) * 0.06;
  }.bind(this)
});
