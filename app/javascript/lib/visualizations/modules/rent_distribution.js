import { extent } from "d3-array";
import { axisBottom, axisRight } from "d3-axis";
import { json } from "d3-fetch";
import { format, formatDefaultLocale } from "d3-format";
import { scaleLinear, scaleLog, scaleSequential } from "d3-scale";
import { interpolatePlasma } from "d3-scale-chromatic";
import { mouse, select, selectAll } from "d3-selection";
import { accounting, d3locale } from "lib/shared";
import { distanceLimitedVoronoi } from "./d3-distance-limited-voronoi.js";

const d3 = {
  format,
  formatDefaultLocale,
  scaleLog,
  scaleLinear,
  scaleSequential,
  axisBottom,
  axisRight,
  select,
  json,
  interpolatePlasma,
  distanceLimitedVoronoi,
  extent,
  selectAll,
  mouse
};

export class VisRentDistribution {
  constructor(divId, city_id) {
    this.container = divId;
    this.cityId = city_id;

    this.data = null;
    this.tbiToken = window.populateData.token;

    this.url =
      window.populateData.endpoint +
      `
      WITH maxyear AS
        (SELECT max(year)
        FROM renta_habitante
        WHERE renta_media_hogar IS NOT NULL)
      SELECT
        place_id AS location_id,
        poblacion_residente::integer AS value,
        renta_media_hogar::decimal AS rent,
        nombre AS municipality_name
      FROM renta_habitante
      INNER JOIN municipios ON codigo_ine = place_id
      WHERE year =
          (SELECT *
          FROM maxyear)
        AND place_id
          BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
          AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
        AND poblacion_residente IS NOT NULL
      `;

    this.formatThousand = d3.format(",.0f");
    this.isMobile = window.innerWidth <= 768;

    // Set default locale
    d3.formatDefaultLocale(d3locale[I18n.locale]);

    // Chart dimensions
    this.margin = { top: 25, right: 15, bottom: 30, left: 15 };
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleLog();
    this.yScale = d3.scaleLinear();

    this.color = d3.scaleSequential(d3.interpolatePlasma);

    // Create axes
    this.xAxis = d3.axisBottom();
    this.yAxis = d3.axisRight();

    // Chart objects
    this.svg = null;

    // Create main elements
    this.svg = d3
      .select(this.container)
      .append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .style("overflow", "visible")
      .append("g")
      .attr("class", "chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    // Append axes containers
    this.svg.append("g").attr("class", "x axis");
    this.svg.append("g").attr("class", "y axis");

    this.tooltip = d3
      .select(this.container)
      .append("div")
      .attr("class", "tooltip");

    d3.select(window).on("resize." + this.container, () => {
      if (this.data) {
        this._resize();
      }
    });
  }

  handlePromise(url, opts = {}) {
    return json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then((jsonData) => {
      this.data = jsonData.data

      this.updateRender();
      this._renderCircles();
      this.isMobile ? null : this._renderVoronoi();
    });
  }

  render() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  }

  updateRender() {
    this.xScale
      .rangeRound([0, this.width])
      .domain(d3.extent(this.data, d => d.value)).nice();

    this.yScale
      .rangeRound([this.height, 0])
      .domain(d3.extent(this.data, d => d.rent));

    this.color.domain(d3.extent(this.data, d => d.rent).reverse());

    this._renderAxis();
  }

  _renderCircles() {
    // We keep this separate to not create them after every resize
    var circles = this.svg
      .append("g")
      .attr("class", "circles")
      .selectAll("circle")
      .data(this.data)
      .enter();

    circles
      .append("circle")
      .attr("class", (d, i) => {
        return d.location_id === +this.cityId
          ? "circle" + i + " selected-city"
          : "circle" + i;
      })
      .attr("cx", d => this.xScale(d.value))
      .attr("cy", d => this.yScale(d.rent))
      .attr("fill", d => this.color(d.rent))
      .attr("stroke", "white")
      .attr("r", this.isMobile ? 6 : 12);

    // Add name of the current city
    var cityLabel = this.svg.append("g").attr("class", "text-label");

    // cityLabel.append()

    cityLabel
      .selectAll("text")
      .data(this.data)
      .enter()
      .filter(d => d.location_id === +this.cityId)
      .append("text")
      .attr("x", d => this.xScale(d.value))
      .attr("y", d => this.yScale(d.rent))
      .attr("dy", 7)
      .attr("dx", -15)
      .attr("text-anchor", "end")
      .text(d => d.municipality_name);
  }

  _renderVoronoi() {
    // Create voronoi
    this.voronoi = d3
      .distanceLimitedVoronoi()
      .x(d => this.xScale(d.value))
      .y(d => this.yScale(+d.rent))
      .limit(50)
      .extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup = this.svg.append("g").attr("class", "voronoi");

    this.voronoiGroup
      .selectAll("path")
      .data(this.voronoi(this.data))
      .enter()
      .append("path")
      .style("fill", "transparent") // with none the event didn't trigger
      .style("mouse-events", "all")
      .attr("class", "voronoiPath")
      .attr("d", d => (d || {}).path)
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this));

    // Attach hover circle
    this.svg
      .append("circle")
      .style("mouse-events", "none")
      .attr("class", "hover")
      .attr("fill", "none")
      .attr("transform", "translate(-100,-100)")
      .attr("r", this.isMobile ? 6 : 12);
  }

  _mousemove(d, i) {
    d3.select('.circle' + i).attr('stroke', 'none')
    // d3.select(".circle").attr("stroke", "none");

    d3.selectAll(".hover")
      .attr("stroke", "#111")
      .attr("stroke-width", 1.5)
      .attr("cx", this.xScale(d.datum.value))
      .attr("cy", this.yScale(d.datum.rent))
      .attr("transform", "translate(0,0)");

    // Fill the tooltip
    this.tooltip
      .html(
        '<div class="tooltip-city">' +
          d.datum.municipality_name +
          "</div>" +
          '<table class="tooltip-table">' +
          '<tr class="first-row">' +
          '<td class="table-t">' +
          I18n.t("gobierto_common.visualizations.inhabitants") +
          "</td>" +
          '<td><span class="table-n">' +
          accounting.formatNumber(d.datum.value, 0) +
          "</span></td>" +
          "</tr>" +
          '<tr class="second-row">' +
          '<td class="table-t">' +
          I18n.t("gobierto_common.visualizations.gross_income") +
          "</td>" +
          "<td>" +
          accounting.formatNumber(d.datum.rent, 0) +
          "€</td>" +
          "</tr>" +
          "</table>"
      )
      .style("opacity", 1);

    // Tooltip position
    if (this.isMobile) {
      this.tooltip.style("opacity", 0);
    } else {
      var coords = d3.mouse(d3.select(this.container)._groups[0][0]);
      // var coords = d3.mouse(event);
      var x = coords[0],
        y = coords[1];

      this.tooltip.style("top", y + 23 + "px");

      if (x > 900) {
        // Move tooltip to the left side
        return this.tooltip.style("left", x - 200 + "px");
      } else {
        return this.tooltip.style("left", x - 20 + "px");
      }
    }
  }

  _mouseout() {
    d3.selectAll(".circle").attr("stroke", "white");

    d3.select(".hover").attr("stroke", "none");

    this.tooltip.style("opacity", 0);
  }

  _renderAxis() {
    // X axis
    this.svg
      .select(".x.axis")
      .attr("transform", "translate(0," + this.height + ")");

    this.xAxis
      .tickPadding(10)
      .ticks(3)
      .tickSize(-this.height)
      .scale(this.xScale)
      .tickFormat(this._formatNumberX.bind(this));

    this.svg.select(".x.axis").call(this.xAxis);

    // Y axis
    this.svg
      .select(".y.axis")
      .attr("transform", "translate(" + this.width + " ,0)");

    this.yAxis
      .scale(this.yScale)
      .ticks(this.isMobile ? 3 : 4)
      .tickSize(-this.width)
      .tickFormat(this._formatNumberY.bind(this));

    this.svg.select(".y.axis").call(this.yAxis);

    // Place y axis labels on top of ticks
    this.svg
      .selectAll(".y.axis .tick text")
      .attr("dx", "-3.4em")
      .attr("dy", "-0.55em");

    // Remove the zero on the y axis
    this.svg
      .selectAll(".y.axis .tick")
      .filter(function(d) {
        return d === 0;
      })
      .remove();
  }

  _formatMillionAbbr(x) {
    return (
      d3.format(".0f")(x / 1e6) +
      " " +
      I18n.t("gobierto_common.visualizations.million")
    );
  }

  _formatThousandAbbr(x) {
    return (
      d3.format(".0f")(x / 1e3) +
      " " +
      I18n.t("gobierto_common.visualizations.thousand")
    );
  }

  _formatAbbreviation(x) {
    var v = Math.abs(x);

    return (v >= 0.9995e6
      ? this._formatMillionAbbr
      : v >= 0.9995e4
      ? this._formatThousandAbbr
      : this.formatThousand)(x);
  }

  _formatNumberX(d) {
    // Spanish custom thousand separator
    return this._formatAbbreviation(d);
  }

  _formatNumberY(d) {
    // Show percentages
    return accounting.formatNumber(d, 0) + "€";
  }

  _width() {
    return d3.select(this.container).node()
      ? parseInt(d3.select(this.container).style("width"))
      : 0;
  }

  _height() {
    return this.isMobile ? 320 : this._width() * 0.5;
  }

  _resize() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + " svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom);

    this.svg
      .select(".chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    this.svg
      .selectAll(".circles circle")
      .attr("cx", d => this.xScale(d.value))
      .attr("cy", d => this.yScale(d.rent));

    this.svg
      .select(".text-label text")
      .attr("x", d => this.xScale(d.value))
      .attr("y", d => this.yScale(d.rent));

    this.svg.selectAll(".rent-anno").attr("x", this.width - 65);

    if (this.voronoi) {
      this.voronoi.extent([[0, 0], [this.width, this.height]]);

      this.voronoiGroup
        .selectAll(".voronoiPath")
        .data(this.voronoi(this.data))
        .attr("d", d => (d || {}).path);
    }
  }
}
