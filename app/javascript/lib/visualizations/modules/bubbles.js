import * as __d3 from 'd3'
import { wordwrap } from 'd3-jetpack'
import { d3locale, accounting } from 'lib/shared'

const d3 = { ...__d3, wordwrap }

export class VisBubbles {
  constructor(divId, budgetCategory, data) {
    this.container = divId;
    d3.select(this.container).html('');
    this.currentYear = parseInt(d3.select('body').attr('data-year'));
    this.data = data;
    this.budget_category = budgetCategory;
    this.forceStrength = 0.045;
    this.isMobile = window.innerWidth <= 590;
    this.locale = I18n.locale;

    d3.formatDefaultLocale(d3locale[this.locale]);

    this.margin = {top: 20, right: 10, bottom: 20, left: 10}
    this.width = parseInt(d3.select(this.container).parent().node().getBoundingClientRect().width) - this.margin.left - this.margin.right;
    this.height = this.isMobile ? 320 : 520 - this.margin.top - this.margin.bottom;
    this.center = { x: this.width / 2, y: this.height / 2 };

    this.selectionNode = d3.select(this.container).node();

    this.budgetColor = d3.scaleThreshold()
      .domain([-30, -10, -5, 0, 5, 10, 30, 100])
      .range(['#b2182b','#d6604d','#f4a582','#fddbc7','#f7f7f7','#d1e5f0','#92c5de','#4393c3','#2166ac']);

    this.fontSize = d3.scaleLinear()
      .domain([0, 90])
      .range([0, 22]);

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
  }

  render() {
    this.updateRender();
  }

  resize() {
    this.svg.parent().remove();
    this.init(this.container, this.budget_category, this.data);
    this.render();
  }

  createNodes(rawData, year) {
    var data = rawData;
    if(this.locale === 'en') this.locale = 'es';

    this.maxAmount = d3.max(data, function (d) { return d.values[year] }.bind(this));
    this.filtered = data.filter(function(d) { return d.budget_category === this.budget_category; }.bind(this));

    this.radiusScale = d3.scaleSqrt()
      .range(this.isMobile ? [0, 80] : [0, 120])
      .domain([0, this.maxAmount]);

    // Assigns the nodes an initial y before the force takes place
    this.nodeScale = d3.scaleLinear()
      .range([0, 500]) // SVG coordinates
      .domain([80, -80]) // Percentage diff between this year and last
      .clamp(true);

    // If we enter for the first time, we build the data
    // If we update, we update the data but not the x and the y
    if (!this.nodes.length > 0) {
      this.nodes = this.filtered.map(function (d) {
        return {
          values: d.values,
          pct_diffs: d.pct_diff,
          id: d.id,
          values_per_inhabitant: d.values_per_inhabitant,
          radius: d.values[year] ? this.radiusScale(d.values[year]) : 0,
          value: d.values[year],
          name: d['level_2_' + this.locale],
          pct_diff: d.pct_diff[year],
          per_inhabitant: d.values_per_inhabitant[year],
          x: Math.random() * 600,
          y: d.pct_diff[year] ? this.nodeScale(d.pct_diff[year]) : 0,
          year: year
        };
      }.bind(this))
    } else {
      this.nodes.forEach(function(d) {
        d.radius = this.radiusScale(d.values[year])
        d.radius = d.values[year] ? this.radiusScale(d.values[year]) : 0
        d.value = d.values[year]
        d.pct_diff = d.pct_diffs[year]
        d.per_inhabitant = d.values_per_inhabitant[year]
        d.year = year
      }.bind(this))
    }

    this.nodes.sort(function (a, b) { return b.value - a.value; });

    return this.nodes;
  }

  update(year) {
    var t = d3.transition()
      .duration(500);

    this.nodes = this.createNodes(this.data, year);
    this.bubbles.data(this.nodes, function (d) { return d.id; })

    d3.selectAll('.bubble')
      .data(this.nodes, function (d) { return d.name; })
      .attr('class', function(d) { return 'bubble bubble-' + d.year})
      .transition(t)
      .attr('r', function (d) { return d.radius; })
      .attr('fill', function(d) { return this.budgetColor(d.pct_diff)}.bind(this))

    d3.selectAll('.bubble-g text')
      .data(this.nodes, function (d) { return d.name; })
      .transition(t)
      .attr('fill', function(d) { return d.pct_diff > 30 || d.pct_diff < -10 ? 'white' : 'black'; })
      .style('font-size', function(d) { return this.fontSize(d.radius) + 'px'; }.bind(this))

    this.simulation.nodes(this.nodes)
    this.simulation.alpha(1).restart();
  }

  updateRender() {

    // var budgetCategory = this.budget_category;
    this.nodes = this.createNodes(this.data, this.currentYear);

    this.bubbles = this.svg.selectAll('g')
      .data(this.nodes, function (d) { return d.name; })
      .enter()
      .append('g')
      .attr('class', 'bubble-g');

    var bubblesG = this.bubbles.append('a')
      .attr('xlink:href', function(d) {
        return this.budget_category === 'income' ? '/presupuestos/partidas/' + d.id + '/' + d.year + '/economic/I' : '/presupuestos/partidas/' + d.id + '/' + d.year + '/functional/G';
      }.bind(this))
      .attr('target', '_top')
      .append('circle')
      .attr('class', function(d) { return d.year + ' bubble'})
      .attr('r', function (d) { return d.radius; })
      .attr('fill', function(d) { return this.budgetColor(d.pct_diff)}.bind(this))
      .attr('stroke-width', 2)
      .on('mousemove', !this.isMobile && this._mousemoved.bind(this))
      .on('mouseleave', !this.isMobile && this._mouseleft.bind(this));

    this.bubbles = this.bubbles.merge(bubblesG);

    this.bubbles.append('text')
      .style('font-size', function(d) { return this.fontSize(d.radius) + 'px'; }.bind(this))
      .attr('text-anchor', 'middle')
      .attr('y', -15)
      .attr('fill', function(d) { return d.pct_diff > 30 || d.pct_diff < -10 ? 'white' : 'black'; })
      .tspans(function(d) { return d.radius > 40 ? d3.wordwrap(d.name, 15) : d3.wordwrap('', 15); }, function(d) { return this.fontSize(d.radius);}.bind(this));

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
  }

  _ticked() {
    this.bubbles.attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')' })
  }

  _mousemoved(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0], y = coordinates[1];

    this.tooltip
      .style('display', 'block')
      .style('left', (x - 110) + 'px')
      .style('top', (y + 40) + 'px');

    function getString(d) {
      return d > 0 ? I18n.t('gobierto_common.visualizations.main_budget_levels_tooltip_up') : I18n.t('gobierto_common.visualizations.main_budget_levels_tooltip_down');
    }
    function perInhabitantTooltipStr(d) {
      return d ? '<div class="clear_b">' + accounting.formatMoney(d, "€", 0, ".", ",") + ' ' + I18n.t('gobierto_common.visualizations.main_budget_levels_per_inhabitant') + '</div>' : '';
    }

    this.tooltip.html('<div class="line-name"><strong>' + d.name + '</strong></div> \
                       <div>' + accounting.formatMoney(d.value, "€", 0, ".", ",") + '</div> \
                       ' + perInhabitantTooltipStr(d.per_inhabitant) + ' \
                       <div class="line-pct">' + getString(d.pct_diff) + ' ' + accounting.formatNumber(d.pct_diff, 1) + ' %</span> ' + I18n.t('gobierto_common.visualizations.main_budget_levels_tooltip_article') + ' ' + (d.year - 1) + '</div>');
  }

  _mouseleft() {
    this.tooltip.style('display', 'none');
  }

  _charge(d) {
    return -Math.pow(d.radius, 2) * 0.06;
  }
}
