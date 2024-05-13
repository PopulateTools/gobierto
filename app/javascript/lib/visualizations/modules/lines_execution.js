import { max } from 'd3-array';
import { axisBottom, axisTop } from 'd3-axis';
import { nest } from 'd3-collection';
import { rgb } from 'd3-color';
import { json } from 'd3-fetch';
import { format, formatDefaultLocale } from 'd3-format';
import {
  scaleBand,
  scaleLinear,
  scaleLog,
  scaleOrdinal,
  scaleTime
} from 'd3-scale';
import { mouse, select, selectAll } from 'd3-selection';
import { timeFormat, timeFormatDefaultLocale, timeParse } from 'd3-time-format';
import { transition } from 'd3-transition';
import { flatten } from 'lodash';
import { GOBIERTO_BUDGETS } from '../../../lib/events';
import { accounting, d3locale } from '../../../lib/shared';

const d3 = {
  select,
  selectAll,
  mouse,
  format,
  formatDefaultLocale,
  timeFormatDefaultLocale,
  timeParse,
  timeFormat,
  transition,
  scaleOrdinal,
  scaleTime,
  scaleLog,
  scaleLinear,
  scaleBand,
  axisBottom,
  axisTop,
  json,
  max,
  rgb,
  nest
};

export class VisLinesExecution {
  constructor(divId, type, category) {
    // Set default locale based on the app setting
    this.locale = I18n.locale;
    this.localeFallback = this.locale === "en" ? "es" : this.locale;

    d3.formatDefaultLocale(d3locale[this.locale]);
    d3.timeFormatDefaultLocale(d3locale[this.locale]);

    this.container = divId;
    this.data = null;
    this.executionKind = type;
    this.budgetCategory = category;
    this.placeId = d3.select("body").attr("data-place-id");
    this.parseTime = d3.timeParse("%Y-%m-%d");
    this.pctFormat = d3.format(",");
    this.monthFormat = d3.timeFormat("%B %Y");
    this.dayFormat = d3.timeFormat("%e %B %Y");
    this.isMobile = window.innerWidth <= 768;
    this.selectionNode = d3.select(this.container).node();
    this.currentYear = new Date().getFullYear();
    this.budgetYear = d3.select("body").attr("data-year");

    // Income and expenses colors
    this.color = d3
      .scaleOrdinal()
      .domain(["I", "G"])
      .range(["#f88f59", "#00909e"]);

    // Create axes
    this.xAxis = d3.axisBottom();

    // Chart objects
    this.svg = null;
    this.chart = null;

    this.tooltip = d3
      .select(this.container)
      .append("div")
      .attr("class", "tooltip");
  }

  getData() {
    this.dataUrl =
      "/presupuestos/api/data/widget/budget_execution_comparison/" +
      this.placeId +
      "/" +
      this.budgetYear +
      "/" +
      this.executionKind +
      "/" +
      this.budgetCategory +
      ".json";

    d3.json(this.dataUrl).then(jsonData => {
      this.data = jsonData;

      // Setting scales in a separate step, as we need the lines to set the height
      this.setScales();
      this.updateRender();

      var event;
      if (typeof Event === "function") {
        event = new Event(GOBIERTO_BUDGETS.LOADED);
      } else {
        event = document.createEvent("Event");
        event.initEvent(GOBIERTO_BUDGETS.LOADED, true, true);
      }

      window.dispatchEvent(event);
    });
  }

  render() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  }

  setScales() {
    if (this.svg) {
      // Destroy the container and render again
      this.svg.node().parentNode.remove();
      this.isMobile = window.innerWidth <= 768;
      this.render();
    }

    // Chart dimensions
    this.margin = {
      top: 55,
      right: 0,
      bottom: 50,
      left: this.isMobile ? 0 : 385
    };
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    this.maxPct = d3.max(this.data.lines, function(d) {
      return d.pct_executed;
    });

    // Triggered if a budget line's execution is over 500%
    this.bigDeviation = this.maxPct > 500;

    // Scales & Ranges
    this.x = this.bigDeviation
      ? d3.scaleLog().range([0.1, this.width])
      : d3
          .scaleLinear()
          .range([0, this.width])
          .clamp(true);
    this.z = d3.scaleTime().range([0, this.width]);
    this.y0 = d3
      .scaleBand()
      .rangeRound([this.height, 0])
      .paddingInner(0.5);
    this.y1 = d3
      .scaleBand()
      .rangeRound([this.height, 0])
      .paddingInner(0.5)
      .paddingOuter(0);

    // Create main elements
    this.svg = d3
      .select(this.container)
      .append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      // NOTE: Height is set later, after elements rendered
      // .attr('height', this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("class", "chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    this.xAxis = d3
      .axisTop(this.x)
      .tickFormat(
        function(d) {
          return d === 0 ? "" : this.pctFormat(d) + "%";
        }.bind(this)
      )
      .tickSize(-this.height - this.margin.bottom)
      .tickPadding(10)
      .ticks(this.isMobile ? 2 : this.bigDeviation ? 3 : 5);

    // Message if custom lines are empty
    if (this.data.lines.length === 0) {
      d3.select(this.container)
        .append("div")
        .attr("class", "flash-message alert")
        .text(I18n.t("gobierto_common.visualizations.empty_lines"));
    }
  }

  updateRender() {
    // d3v5
    //
    this.nested = d3
      .nest()
      .key(function(d) {
        return d.parent_id;
      })
      .sortValues(function(a, b) {
        // Parent lines are the first for each group, and then child lines are sorted by execution rate
        return a.level === 1 || b.level === 1 ? b.level - a.level : b.id - a.id;
      })
      .entries(this.data.lines);

    // d3v6
    //
    // this.nested = Array.from(
    //   d3.group(this.data.lines, d => d.parent_id),
    //   ([key, values]) => ({ key, values })
    // );

    this.nested.forEach(d => {
      d.values = d.values.sort((a, b) =>
        a.level === 1 || b.level === 1 ? b.level - a.level : b.id - a.id
      );

      // Get parent line values for each group to sort them later
      d.group_pct = d.values
        .filter(d => d.level == 1)
        .map(d => d.pct_executed)[0];
      d.group_executed = d.values
        .filter(d => d.level == 1)
        .map(d => d.executed)[0];

      return d;
    });

    if (this.data.lines.length === 0) return false;

    // Sort by execution
    this.nested.sort((a, b) => a.group_pct - b.group_pct);

    /* Extent of the execution */
    this.x.domain(this.maxPct <= 100 ? [0.1, 100] : [0.1, this.maxPct]);

    /* Number of lines */
    this.y0.domain(this.nested.map(d => d.key));

    /* Get the id of every line */
    this.y1.domain(flatten(this.nested.map(d => d.values.map(v => v.id))));

    /* A time scale which spreads along the whole chart */
    this.z.domain([
      this.parseTime(this.currentYear + "-01-01"),
      this.parseTime(this.currentYear + "-12-31")
    ]);

    this.bars = this.svg
      .selectAll("g")
      .data(this.nested)
      .enter()
      .append("g")
      .attr("class", "line-group")
      .attr(
        "transform",
        d => "translate(" + 0 + "," + this.y0(d.key) / 14 + ")"
      );

    var lineGroup = this.bars
      .selectAll("a")
      .data(d => d.values)
      .enter()
      .append("a")
      .attr("class", "line")
      .attr("xlink:href", d => {
        return (
          "/presupuestos/partidas/" +
          d.id +
          "/" +
          this.budgetYear +
          "/" +
          this.budgetCategory +
          "/" +
          this.executionKind
        );
      })

    var barGroup = lineGroup
      .append("g")
      .attr("class", "bar-group")
      .on("mousemove", this._mousemoved.bind(this))
      .on("mouseleave", this._mouseleft.bind(this));

    barGroup
      .append("rect")
      .attr("class", "bar-bg")
      .attr("x", 0)
      .attr("height", this.y1.bandwidth())
      .attr("y", d => this.y1(d.id))
      .attr("width", this.x(this.x.domain()[1]))
      .attr("fill", "#efefef");

    /* White bar marking 100% completion */
    barGroup
      .append("line")
      .attr("class", "hundred_percent")
      .attr("x1", this.x(100))
      .attr("x2", this.x(100))
      .attr("y1", d => this.y1(d.id))
      .attr("y2", d => this.y1(d.id) + this.y1.bandwidth())
      .attr("stroke", "white")
      .attr("stroke-width", 4);

    /* Main bar */
    barGroup
      .append("rect")
      .attr("class", "bar")
      .attr("x", 0)
      .attr("height", this.y1.bandwidth())
      .attr("y", d => this.y1(d.id))
      .attr("width", d => {
        if (d.pct_executed == 0) {
          return 0;
        } else {
          return this.x(d.pct_executed);
        }
      })
      .attr("fill", d => {
        var levelTwoColor = d3.rgb(this.color(this.executionKind));
        levelTwoColor.opacity = this.isMobile ? 0.3 : 0.5;

        return d.level === 1 ? this.color(this.executionKind) : levelTwoColor;
      });

    /* Line names */
    if (!this.isMobile) {
      lineGroup
        .append("text")
        .attr("x", 0)
        .attr("y", d => this.y1(d.id))
        .attr("dy", 12)
        .attr("dx", -10)
        .attr("text-anchor", "end")
        .attr("class", d =>
          d.level === 1 ? "line-txt-group" : "line-txt-detail"
        )
        .text(d => d["name_" + this.localeFallback])
        .on("mousemove", function() {
          $(this)
            .prev()
            .css("stroke", "black");
        })
        .on("mouseleave", function() {
          $(this)
            .prev()
            .css("stroke", "none");
        })
        .append("title")
        .text(d => d["name_" + this.localeFallback]);
    } else {
      lineGroup
        .append("text")
        .attr("x", 0)
        .attr("y", d => this.y1(d.id))
        .attr("dy", 12)
        .attr("dx", 2)
        .attr("text-anchor", "start")
        .style("text-shadow", d => (d.level === 1 ? "0 0 4px white" : ""))
        .style("font-size", d => (d.level === 1 ? "0.875rem" : "0.75rem"))
        .style("font-weight", d => (d.level === 1 ? "600" : "400"))
        .style("fill", "#4A4A4A")
        .text(d => d["name_" + this.localeFallback])
        .style("mouse-events", "none");
    }

    this.svg
      .append("g")
      .attr("class", "x axis")
      .call(this.xAxis);

    /* Legend */
    var legend = this.svg
      .append("g")
      .attr("class", "legend")
      .attr("transform", "translate(0, -10)");

    if (!this.isMobile) {
      legend
        .append("text")
        .attr("text-anchor", "end")
        .attr("dx", "-12")
        .text(I18n.t("gobierto_common.visualizations.lines_title"));
    }

    legend
      .append("text")
      .attr("class", "legend-value halo")
      .text(
        this.bigDeviation
          ? I18n.t("gobierto_common.visualizations.percent_log")
          : I18n.t("gobierto_common.visualizations.percent")
      )
      .attr("stroke", "white")
      .attr("stroke-width", 5);

    legend
      .append("text")
      .attr("class", "legend-value")
      .text(
        this.bigDeviation
          ? I18n.t("gobierto_common.visualizations.percent_log")
          : I18n.t("gobierto_common.visualizations.percent")
      );

    /* Remove first tick */
    d3.selectAll(".x.axis .tick")
      .filter(d => d === 0 || d === 0.1)
      .remove();

    /* Style 100% completion */
    d3.selectAll(".x.axis .tick")
      .filter(d => d === 100)
      .classed("hundred_percent", true);

    /* Switch to absolute values */
    $(".value-switcher-" + this.executionKind).on("click", e => {
      var valueKind = $(e.target).attr("data-toggle");
      var symbol = $(e.target).attr("data-symbol");

      $(".value-switcher-" + this.executionKind).removeClass("active");
      $(e.target).addClass("active");

      this._update(valueKind, symbol);
    });

    /* Trigger sorting functions */
    $(".sort-" + this.executionKind).on("click", e => {
      var sortKind = $(e.target).attr("data-toggle");

      $(".sort-" + this.executionKind).removeClass("active");
      $(e.target).addClass("active");

      this._sortValues(e.target, sortKind);
    });

    d3.select("body:not(" + this.container + ")").on(
      "touchstart",
      this._mouseleft.bind(this)
    );

    // NOTE: resize container once all data has been displayed
    const node = this.svg.node() || document.createElement("div");
    d3.select(this.container + " svg").attr(
      "height",
      node.getBoundingClientRect().height + this.margin.top
    );
  }

  _update(valueKind, symbol) {
    this.xAxis.tickFormat(d => (d === 0 ? "" : this.pctFormat(d) + symbol));
    this.x.domain([0.1, d3.max(this.data.lines, d => d[valueKind])]);

    this.svg.select(".x.axis").call(this.xAxis);

    this.svg
      .selectAll(".x.axis .tick")
      .filter(d =>
        valueKind === "executed"
          ? d === 0 || d === 0.1 || d === 1
          : d === 0 || d === 0.1
      )
      .remove();

    this.svg
      .selectAll(".x.axis .tick")
      .filter(d => d === 100)
      .classed("hundred_percent", valueKind === "pct_executed" ? true : false);

    this.svg
      .select(".legend-value")
      .text(
        valueKind === "executed"
          ? I18n.t("gobierto_common.visualizations.absolute")
          : I18n.t("gobierto_common.visualizations.percent")
      );

    this.svg
      .selectAll(".hundred_percent")
      .transition()
      .style("opacity", valueKind === "executed" ? 0 : 1);

    this.svg
      .selectAll(".bar")
      .transition()
      .duration(300)
      .attr("width", d => this.x(d[valueKind]));
  }

  _sortValues(target, sortKind) {
    sortKind === "highest"
      ? this.nested.sort((a, b) => a.group_pct - b.group_pct)
      : this.nested.sort((a, b) => b.group_pct - a.group_pct);

    this.y0.domain(
      sortKind === "highest"
        ? this.nested.map(d => d.key)
        : this.nested.map(d => d.key).reverse()
    );

    this.y1.domain(flatten(this.nested.map(d => d.values.map(v => v.id))));

    this.svg
      .selectAll(".line-group")
      .data(this.nested)
      .transition()
      .duration(500)
      .attr(
        "transform",
        d => "translate(" + 0 + "," + this.y0(d.key) / 14 + ")"
      );

    this.svg
      .selectAll(".bar")
      .transition()
      .duration(300)
      .attr("y", d => this.y1(d.id));

    this.svg
      .selectAll(".bar-bg")
      .transition()
      .duration(300)
      .attr("y", d => this.y1(d.id));

    this.svg
      .selectAll(".line text")
      .transition()
      .duration(300)
      .attr("y", d => this.y1(d.id));

    this.svg
      .selectAll(".hundred_percent")
      .transition()
      .duration(300)
      .attr("y1", d => this.y1(d.id))
      .attr("y2", d => this.y1(d.id) + this.y1.bandwidth());
  }

  _mousemoved(d) {
    var coordinates = d3.mouse(this.selectionNode);
    var x = coordinates[0],
      y = coordinates[1];

    this.tooltip
      .style("display", "block")
      .style("left", x - 110 + "px")
      .style("top", y + 40 + "px");

    var tooltipHtml =
      '<div class="line-name"><strong>' +
      d["name_" + this.localeFallback] +
      "</strong></div>" +
      '<div class="line-name">' +
      I18n.t("gobierto_common.visualizations.tooltip_budgeted") +
      ": " +
      accounting.formatMoney(
        d.budget,
        "€",
        0,
        I18n.t("number.currency.format.delimiter"),
        I18n.t("number.currency.format.separator")
      ) +
      "</div>";

    if (d.budget_updated !== null)
      tooltipHtml +=
        '<div class="line-name">' +
        I18n.t("gobierto_common.visualizations.tooltip_budgeted_updated") +
        ": " +
        accounting.formatMoney(
          d.budget_updated,
          "€",
          0,
          I18n.t("number.currency.format.delimiter"),
          I18n.t("number.currency.format.separator")
        ) +
        "</div>";

    tooltipHtml +=
      '<div class="line-name">' +
      I18n.t("gobierto_common.visualizations.tooltip_executed_amount") +
      ": " +
      accounting.formatMoney(
        d.executed,
        "€",
        0,
        I18n.t("number.currency.format.delimiter"),
        I18n.t("number.currency.format.separator")
      ) +
      "</div>";

    tooltipHtml +=
      "<div>" +
      I18n.t("gobierto_common.visualizations.tooltip") +
      " " +
      this.pctFormat(d.pct_executed) +
      " %</div>";

    this.tooltip.html(tooltipHtml);
  }

  _mouseleft() {
    d3.selectAll(".tooltip").style("display", "none");
  }

  _width() {
    return parseInt(d3.select(this.container).style("width"));
  }

  _height() {
    // Height depends on number of lines
    var groupPadding = this.data.lines.filter(d => d.level === 1).length * 10;

    return this.data.lines.length * 30 + groupPadding;
  }
}
