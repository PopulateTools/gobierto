import { max } from 'd3-array';
import {
  forceCollide,
  forceManyBody,
  forceSimulation,
  forceX,
  forceY
} from 'd3-force';
import { formatDefaultLocale } from 'd3-format';
import { scaleLinear, scaleSqrt, scaleThreshold } from 'd3-scale';
import { mouse, select, selectAll, selection } from 'd3-selection';
import { transition } from 'd3-transition';
import { accounting, d3locale, wordwrap, tspans } from '../../../lib/shared';

selection.prototype.tspans = tspans;

const d3 = {
  select,
  selectAll,
  mouse,
  scaleThreshold,
  scaleLinear,
  scaleSqrt,
  forceSimulation,
  forceX,
  forceY,
  forceManyBody,
  forceCollide,
  max,
  formatDefaultLocale,
  transition,
  selection
};

export class VisBubbles {
  constructor(divId, budgetCategory, data) {
    this.container = divId;
    d3.select(this.container).html("");
    this.currentYear = parseInt(d3.select("body").attr("data-year"));
    this.data = data;
    this.budget_category = budgetCategory;
    this.forceStrength = 0.045;
    this.isMobile = window.innerWidth <= 590;
    this.locale = I18n.locale;

    d3.formatDefaultLocale(d3locale[this.locale]);

    this.margin = { top: 20, right: 10, bottom: 20, left: 10 };
    const containerNode =
      d3.select(this.container).node() || document.createElement("div");
    this.width =
      (containerNode.parentNode || containerNode).getBoundingClientRect()
        .width -
      this.margin.left -
      this.margin.right;
    this.height = this.isMobile
      ? 320
      : 520 - this.margin.top - this.margin.bottom;
    this.center = { x: this.width / 2, y: this.height / 2 };

    this.selectionNode = d3.select(this.container).node();

    this.budgetColor = d3
      .scaleThreshold()
      .domain([-30, -10, -5, 0, 5, 10, 30, 100])
      .range([
        "#b2182b",
        "#d6604d",
        "#f4a582",
        "#fddbc7",
        "#f7f7f7",
        "#d1e5f0",
        "#92c5de",
        "#4393c3",
        "#2166ac"
      ]);

    this.fontSize = d3
      .scaleLinear()
      .domain([0, 90])
      .range([0, 22]);

    this.tooltip = d3
      .select(this.container)
      .append("div")
      .attr("class", "tooltip");

    this.nodes = [];

    this.simulation = d3
      .forceSimulation()
      .velocityDecay(0.3)
      .force(
        "x",
        d3
          .forceX()
          .strength(this.forceStrength)
          .x(this.center.x)
      )
      .force(
        "y",
        d3
          .forceY()
          .strength(this.forceStrength)
          .y(this.center.y)
      )
      .force("charge", d3.forceManyBody().strength(this._charge))
      .force(
        "collide",
        d3
          .forceCollide()
          .radius(d => d.radius + 0.5)
          .iterations(2)
      )
      .on("tick", this._ticked.bind(this));

    this.simulation.stop();

    this.svg = d3
      .select(this.container)
      .append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("transform", `translate(${this.margin.left},${this.margin.top})`);
  }

  render() {
    this.updateRender();
  }

  resize() {
    const { parentNode } = this.svg.node();
    if (parentNode) {
      parentNode.remove();
      this.constructor(this.container, this.budget_category, this.data);
      this.render();
    }
  }

  createNodes(rawData, year) {
    var data = rawData;
    if (this.locale === "en") this.locale = "es";

    this.maxAmount = d3.max(
      data,
      function(d) {
        return d.values[year];
      }.bind(this)
    );
    this.filtered = data.filter(
      function(d) {
        return d.budget_category === this.budget_category;
      }.bind(this)
    );

    this.radiusScale = d3
      .scaleSqrt()
      .range(this.isMobile ? [0, 80] : [0, 120])
      .domain([0, this.maxAmount]);

    // Assigns the nodes an initial y before the force takes place
    this.nodeScale = d3
      .scaleLinear()
      .range([0, 500]) // SVG coordinates
      .domain([80, -80]) // Percentage diff between this year and last
      .clamp(true);

    // If we enter for the first time, we build the data
    // If we update, we update the data but not the x and the y
    if (!this.nodes.length > 0) {
      this.nodes = this.filtered.map(
        function(d) {
          return {
            values: d.values,
            pct_diffs: d.pct_diff,
            id: d.id,
            area_name: d.area_name,
            values_per_inhabitant: d.values_per_inhabitant,
            radius: d.values[year] ? this.radiusScale(d.values[year]) : 0,
            value: d.values[year],
            name: d["level_2_" + this.locale],
            pct_diff: d.pct_diff[year],
            per_inhabitant: d.values_per_inhabitant[year],
            x: Math.random() * 600,
            y: d.pct_diff[year] ? this.nodeScale(d.pct_diff[year]) : 0,
            year: year
          };
        }.bind(this)
      );
    } else {
      this.nodes.forEach(
        function(d) {
          d.radius = this.radiusScale(d.values[year]);
          d.radius = d.values[year] ? this.radiusScale(d.values[year]) : 0;
          d.value = d.values[year];
          d.pct_diff = d.pct_diffs[year];
          d.per_inhabitant = d.values_per_inhabitant[year];
          d.year = year;
        }.bind(this)
      );
    }

    this.nodes.sort((a, b) => b.value - a.value);

    return this.nodes;
  }

  update(year) {
    const transitionDuration = 500;

    this.nodes = this.createNodes(this.data, year);
    this.bubbles.data(this.nodes, d => d.id);

    d3.selectAll(".bubble")
      .data(this.nodes, d => d.name)
      .attr("class", d => `bubble bubble-${d.year}`)
      .transition()
      .duration(transitionDuration)
      .attr("r", d => d.radius)
      .attr(
        "fill",
        function(d) {
          return this.budgetColor(d.pct_diff);
        }.bind(this)
      );

    d3.selectAll('.bubble-g a')
      .attr('xlink:href', function(d) { return this.setLink(d); }.bind(this))

    d3.selectAll(".bubble-g text")
      .data(this.nodes, d => d.name)
      .transition()
      .duration(transitionDuration)
      .attr("fill", function(d) {
        return d.pct_diff > 30 || d.pct_diff < -10 ? "white" : "black";
      })
      .style(
        "font-size",
        function(d) {
          return this.fontSize(d.radius) + "px";
        }.bind(this)
      );

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
  }

  setLink(d) {
    var areaName = d.area_name || (this.budget_category === "income" ? "economic" : "functional");
    var budgetCategory = this.budget_category === "income" ? "I" : "G";
    return "/presupuestos/partidas/" + d.id + "/" + d.year + "/" + areaName + "/" + budgetCategory;
  }

  updateRender() {
    // var budgetCategory = this.budget_category;
    this.nodes = this.createNodes(this.data, this.currentYear);

    this.bubbles = this.svg
      .selectAll("g")
      .data(this.nodes, d => d.name)
      .enter()
      .append("g")
      .attr("class", "bubble-g");

    var bubblesG = this.bubbles
      .append("a")
      .attr(
        "xlink:href",
        function(d) { return this.setLink(d); }.bind(this)
      )
      .append("circle")
      .attr("class", d => `${d.year} bubble`)
      .attr("r", d => d.radius)
      .attr(
        "fill",
        function(d) {
          return this.budgetColor(d.pct_diff);
        }.bind(this)
      )
      .attr("stroke-width", 2)
      .on("mousemove", !this.isMobile && this._mousemoved.bind(this))
      .on("mouseleave", !this.isMobile && this._mouseleft.bind(this));

    this.bubbles = this.bubbles.merge(bubblesG);

    this.bubbles
      .append("text")
      .style("font-size", d => this.fontSize(d.radius) + "px")
      .attr("text-anchor", "middle")
      .attr("y", -15)
      .attr("fill", d =>
        d.pct_diff > 30 || d.pct_diff < -10 ? "white" : "black"
      )
      .tspans(
        d => (d.radius > 40 ? wordwrap(d.name, 15) : wordwrap("", 15)),
        d => this.fontSize(d.radius)
      );

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
  }

  _ticked() {
    this.bubbles.attr("transform", d => `translate(${d.x},${d.y})`);
  }

  _mousemoved(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0],
      y = coordinates[1];

    this.tooltip
      .style("display", "block")
      .style("left", `${x - 100}px`)
      .style("top", `${y + 40}px`);

    function getString(d) {
      return d > 0
        ? I18n.t("gobierto_common.visualizations.main_budget_levels_tooltip_up")
        : I18n.t(
            "gobierto_common.visualizations.main_budget_levels_tooltip_down"
          );
    }
    function perInhabitantTooltipStr(d) {
      return d
        ? `<div class="clear_b">${accounting.formatMoney(
            d,
            "€",
            0,
            I18n.t("number.currency.format.delimiter"),
            I18n.t("number.currency.format.separator")
          )} ${I18n.t(
            "gobierto_common.visualizations.main_budget_levels_per_inhabitant"
          )}</div>`
        : "";
    }

    var tooltipEnding;
    if (d.year > new Date().getFullYear()) {
      tooltipEnding = I18n.t(
        "gobierto_common.visualizations.main_budget_levels_tooltip_article_last"
      );
    } else {
      tooltipEnding = `${I18n.t(
        "gobierto_common.visualizations.main_budget_levels_tooltip_article"
      )} ${d.year - 1}`;
    }

    this.tooltip.html(`<div class="line-name"><strong>${d.name}</strong></div>
                      <div>${accounting.formatMoney(
                        d.value,
                        "€",
                        0,
                        I18n.t("number.currency.format.delimiter"),
                        I18n.t("number.currency.format.separator")
                      )}</div>
                        ${perInhabitantTooltipStr(d.per_inhabitant)}
                      <div class="line-pct">${getString(
                        d.pct_diff
                      )} ${accounting.formatNumber(
      d.pct_diff,
      1
    )} %</span> ${tooltipEnding}</div>`);
  }

  _mouseleft() {
    this.tooltip.style("display", "none");
  }

  _charge(d) {
    return -Math.pow(d.radius, 2) * 0.06;
  }
}
