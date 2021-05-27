import { max } from "d3-array";
import {
  forceCollide,
  forceManyBody,
  forceSimulation,
  forceX,
  forceY
} from "d3-force";
import { formatDefaultLocale } from "d3-format";
import { wordwrap } from "d3-jetpack";
import { scaleLinear, scaleSqrt, scaleThreshold } from "d3-scale";
import { mouse, select, selectAll } from "d3-selection";
import { transition } from "d3-transition";
import { accounting, d3locale } from "lib/shared";

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
  wordwrap
};

export class VisBubble {
  constructor(divId, year, data) {
    this.container = divId;
    this.data = data;
    this.year = year;
    this.forceStrength = 0.045;
    this.isMobile = window.innerWidth <= 590;
    this.radiusReponsive = this.isMobile ? 2 : 1.5;
    this.locale = I18n.locale;

    d3.formatDefaultLocale(d3locale[this.locale]);

    this.margin = { top: 20, right: 10, bottom: 20, left: 10 };
    //Get container from Vue Template
    this.containerWidth = document.querySelector(".vis-costs");
    const containerNode = document.getElementById(
      "gobierto-visualizations-bubble-container"
    );
    this.width =
      this.containerWidth.offsetWidth - this.margin.left - this.margin.right;
    this.height = this.isMobile
      ? 320
      : 520 - this.margin.top - this.margin.bottom;
    this.center = { x: this.width / 2, y: this.height / 2 };

    this.selectionNode = containerNode;

    this.budgetColor = d3
      .scaleThreshold()
      .domain([0, 20, 40, 60, 80, 100, 120, 140])
      .range(["#4393c3"]);

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

  resize(year) {
    const { parentNode } = this.svg.node();
    if (parentNode) {
      parentNode.remove();
      this.constructor(this.container, year, this.data);
      this.render();
    }
  }

  createNodes(rawData) {
    var data = rawData;
    if (this.locale === "en") this.locale = "es";

    this.maxAmount = d3.max(
      data,
      function(d) {
        return d.radius;
      }.bind(this)
    );

    this.radiusScale = d3
      .scaleSqrt()
      .range(this.isMobile ? [0, 80] : [0, 120])
      .domain([0, 100]);

    // Assigns the nodes an initial y before the force takes place
    this.nodeScale = d3
      .scaleLinear()
      .range([0, 500]) // SVG coordinates
      .domain([0, 100]) // Percentage diff between this year and last
      .clamp(true);

    // If we enter for the first time, we build the data
    // If we update, we update the data but not the x and the y
    if (!this.nodes.length > 0) {
      this.nodes = rawData.map(
        function(d) {
          return {
            id: d.agrupacio,
            radius: +d.costtotal / (d.population * this.radiusReponsive),
            x: Math.random() * 600,
            y: this.nodeScale(
              +d.costtotal / (d.population * this.radiusReponsive)
            ),
            costtotal: d.costtotal,
            year: d.any_,
            ordreagrup: d.ordreagrup,
            costperhabit: (d.costtotal / d.population).toFixed(2)
          };
        }.bind(this)
      );
    } else {
      this.nodes.forEach(
        function(d) {
          (d.id = d.agrupacio),
            (d.radius = +d.costtotal / (d.population * this.radiusReponsive)),
            (d.costperhabit = (d.costtotal / d.population).toFixed(2));
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
      .data(this.nodes, d => d.id)
      .attr("class", d => "bubble bubble-" + d.year)
      .transition()
      .duration(transitionDuration)
      .attr("r", d => d.radius)
      .attr(
        "fill",
        function(d) {
          return this.budgetColor(d.radius);
        }.bind(this)
      );

    d3.selectAll(".bubble-g text")
      .data(this.nodes, d => d.id)
      .transition()
      .duration(transitionDuration)
      .attr("fill", "white")
      .style(
        "font-size",
        function(d) {
          return this.fontSize(d.radius) + "px";
        }.bind(this)
      );

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
  }

  updateRender() {
    const year = this.year;
    const data = this.data.filter(element => element.any_ === year);

    // var budgetCategory = this.budget_category;
    this.nodes = this.createNodes(data, year);

    this.bubbles = this.svg
      .selectAll("g")
      .data(this.nodes, d => d.id)
      .enter()
      .append("g")
      .attr("class", "bubble-g");

    this.bubbles
      .append("circle")
      .attr("class", d => `${d.year} bubble`)
      .attr("r", d => d.radius)
      .attr(
        "fill",
        function(d) {
          return this.budgetColor(d.radius);
        }.bind(this)
      )
      .attr("stroke-width", 2)
      .on("mousemove", !this.isMobile && this._mousemoved.bind(this))
      .on("mouseleave", !this.isMobile && this._mouseleft.bind(this));

    var bubblesG = this.bubbles
      .append("a")
      .attr(
        "xlink:href",
        function(d) {
          return `/visualizations/costes/${d.year}/${d.ordreagrup}`;
        }.bind(this)
      )
      .attr("class", "bubbles-links")
      .append("circle")
      .attr("class", d => `${d.year} bubble`)
      .attr("data-order", d => d.ordreagrup)
      .attr("data-year", d => d.year)
      .attr("r", d => d.radius)
      .attr(
        "fill",
        function(d) {
          return this.budgetColor(d.radius);
        }.bind(this)
      )
      .on("mousemove", !this.isMobile && this._mousemoved.bind(this))
      .on("mouseleave", !this.isMobile && this._mouseleft.bind(this));

    this.bubbles = this.bubbles.merge(bubblesG);

    this.bubbles
      .append("text")
      .style(
        "font-size",
        function(d) {
          return this.fontSize(d.radius) + "px";
        }.bind(this)
      )
      .attr("text-anchor", "middle")
      .attr("y", -15)
      .attr("fill", "white")
      .tspans(
        function(d) {
          return d.radius > 40 ? d3.wordwrap(d.id, 15) : d3.wordwrap("", 15);
        },
        function(d) {
          return this.fontSize(d.radius);
        }.bind(this)
      );

    this.simulation.nodes(this.nodes);
    this.simulation.alpha(1).restart();
  }

  _ticked() {
    this.bubbles.attr("transform", d => `translate(${d.x},${d.y})`);
  }

  _mousemoved(d) {
    var coordinates = d3.mouse(this.containerWidth);
    var x = coordinates[0],
      y = coordinates[1];

    this.tooltip
      .style("display", "block")
      .style("left", `${x - 100}px`)
      .style("top", `${y + 40}px`);

    this.tooltip.html(`<div class="line-name"><strong>${d.id}</strong></div>
                      <div>${I18n.t(
                        "gobierto_visualizations.visualizations.costs.total_cost"
                      )}: ${accounting.formatMoney(
      d.costtotal,
      "€",
      0,
      I18n.t("number.currency.format.delimiter"),
      I18n.t("number.currency.format.separator")
    )}</div>
                        ${d.costperhabit}€ ${I18n.t(
      "gobierto_visualizations.visualizations.costs.per_inhabitant"
    )}`);
  }

  _mouseleft() {
    this.tooltip.style("display", "none");
  }

  _charge(d) {
    return -Math.pow(d.radius, 2) * 0.06;
  }
}

