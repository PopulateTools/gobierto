import * as d3 from 'd3';
import { voronoi } from 'd3-voronoi';
import { d3locale, groupBy } from '../../../lib/shared';

export class VisUnemploymentRate {
  constructor(divId, city_id) {
    this.container = divId;
    this.data = null;
    this.tbiToken = window.populateData.token;

    this.url =
      window.populateData.endpoint +
      `
      WITH pob_activa AS
        (SELECT year,
                SUM(total::integer) AS value
        FROM poblacion_edad_sexo
        WHERE place_id = ${city_id}
          AND sex = 'Total'
          AND age BETWEEN 16 AND 65
        GROUP BY year
        ORDER BY 1 DESC),
          pob_activa_prov AS
        (SELECT year,
                SUM(total::integer) AS value
        FROM poblacion_edad_sexo
        WHERE
          place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
          AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
          AND sex = 'Total'
          AND age BETWEEN 16 AND 65
        GROUP BY year
        ORDER BY 1 DESC)
      SELECT 1 AS key,
            paro.year,
            month,
            CONCAT(paro.year, '-', month, '-', 1) AS date,
            SUM(paro.value::decimal) / COALESCE(pob_activa.value, (SELECT value FROM pob_activa LIMIT 1)) AS value
      FROM paro_personas paro
      LEFT JOIN pob_activa ON paro.year = pob_activa.year
      WHERE place_id = ${city_id}
      GROUP BY paro.year,
              month,
              pob_activa.value
      UNION
      SELECT 2 AS key,
            paro.year,
            month,
            CONCAT(paro.year, '-', month, '-', 1) AS date,
            SUM(paro.value::decimal) / COALESCE(pob_activa_prov.value, (SELECT value FROM pob_activa_prov LIMIT 1)) AS value
      FROM paro_personas paro
      LEFT JOIN pob_activa_prov ON paro.year = pob_activa_prov.year
      WHERE
        place_id BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
        AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
      GROUP BY paro.year,
              month,
              pob_activa_prov.value
      ORDER BY key, year DESC, month DESC
      `;

    d3.timeFormatDefaultLocale(d3locale[I18n.locale]);

    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = { top: 25, right: 80, bottom: 25, left: 0 };
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleTime();
    this.yScale = d3.scaleLinear();
    this.color = d3.scaleOrdinal();

    // Create axes
    this.xAxis = d3.axisBottom();
    this.yAxis = d3.axisLeft();

    // Chart objects
    this.svg = null;

    // Create main elements
    this.svg = d3.select(this.container)
      .append("svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)
      .append("g")
      .attr("class", "chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    // Append axes containers
    this.svg.append("g").attr("class", "x axis");
    this.svg.append("g").attr("class", "y axis");

    d3.select(window).on("resize." + this.container, () => {
      if (this.data) {
        this._resize();
      }
    });
  }

  handlePromise(url, opts = {}) {
    return d3.json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  getData() {
    var data = this.handlePromise(this.url);

    data.then(json => {
      this.data = Object.entries(groupBy(json.data, "key"));

      this.updateRender();
      this._renderLines();
      this._renderVoronoi();
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
    const values = this.data.flatMap(x => x[1]);

    this.xScale
      .rangeRound([0, this.width])
      .domain(d3.extent(values, d => new Date(d.date)));

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0, d3.max(values, d => d.value)]);

    this.color
      .domain([...new Set(values.map(x => x.key))])
      .range(["#F6B128", "#F39D96"]);

    this._renderAxis();
  }

  _renderLines() {
    this.line = d3.line()
      .x(d => this.xScale(new Date(d.date)))
      .y(d => this.yScale(+d.value));
    // .curve(curveCatmullRom.alpha(0.5));

    var lines = this.svg
      .append("g")
      .attr("class", "lines")
      .selectAll("path")
      .data(this.data, ([key]) => key)
      .enter();

    var linesGroup = lines.append("g").attr("class", "line");

    linesGroup
      .append("path")
      .attr("d", ([, values]) => this.line(values))
      .attr("stroke", ([key]) => this.color(key));

    linesGroup
      .append("circle")
      .attr("cx", ([, values]) => this.xScale(new Date(values[0].date)))
      .attr("cy", ([, values]) => this.yScale(values[0].value))
      .attr("r", 5)
      .attr("fill", ([key]) => this.color(key));

    var linesText = d3.select(this.container)
      .append("div")
      .attr("class", "lines-labels")
      .selectAll("p")
      .data(this.data, ([key]) => key)
      .enter();

    linesText
      .append("div")
      .style("right", "10px")
      .style("top", ([, values]) => this.yScale(values[0].value) + "px")
      .text(([key]) => this._getPlaceType(key));
  }

  _renderVoronoi() {
    this.focus = this.svg
      .append("g")
      .attr("transform", "translate(-100,-100)")
      .attr("class", "focus");

    this.focus
      .append("circle")
      .attr("fill", "white")
      .attr("r", 5);

    this.text = this.focus.append("text");

    this.text
      .append("tspan")
      .attr("y", -10)
      .attr("x", 0);

    this.voronoi = voronoi()
      .x(d => this.xScale(new Date(d.date)))
      .y(d => this.yScale(+d.value))
      .extent([
        [0, 0],
        [this.width, this.height]
      ]);

    this.voronoiGroup = this.svg.append("g").attr("class", "voronoi");

    this.voronoiGroup
      .selectAll("path")
      .data(this.voronoi.polygons(this.data.flatMap(x => x[1])))
      .enter()
      .append("path")
      .attr("d", function(d) {
        return d ? "M" + d.join("L") + "Z" : null;
      })
      .on("mouseover", this._mouseover.bind(this))
      .on("mouseout", this._mouseout.bind(this));
  }

  _mouseover(_, d) {
    this.focus.select("circle").attr("stroke", this.color(d.data.key));

    this.focus.attr(
      "transform",
      "translate(" +
        this.xScale(new Date(d.data.date)) +
        "," +
        this.yScale(+d.data.value) +
        ")"
    );

    const [startDate, endDate] = this.xScale.domain()
    const middleDate = new Date((startDate.getTime() + endDate.getTime()) / 2);

    this.focus
      .select("text")
      .attr(
        "text-anchor",
        new Date(d.data.date) >= middleDate ? "end" : "start"
      );

    const month = d3.timeFormat("%b %Y")(new Date(d.data.date));
    const value = Number(d.data.value).toLocaleString(I18n.locale, {
      style: "percent",
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });

    this.focus
      .select("tspan")
      .text(`${this._getPlaceType(d.data.key)}: ${value} (${month})`);
  }

  _mouseout() {
    this.focus.attr("transform", "translate(-100,-100)");
  }

  _renderAxis() {
    // X axis
    this.svg
      .select(".x.axis")
      .attr("transform", "translate(0," + this.height + ")");

    this.xAxis
      .ticks(4)
      .tickPadding(10)
      .tickSize(0, 0)
      .scale(this.xScale);

    this.yAxis
      .ticks(3)
      .tickSize(-this.width)
      .tickFormat(d => d.toLocaleString(I18n.locale, { style: "percent" }))
      .scale(this.yScale);

    this.svg.select(".x.axis").call(this.xAxis);
    this.svg.select(".y.axis").call(this.yAxis);

    // Remove the zero
    this.svg
      .selectAll(".y.axis .tick")
      .filter(function(d) {
        return d === 0;
      })
      .remove();

    // Move y axis ticks on top of the chart
    this.svg
      .selectAll(".y.axis .tick text")
      .attr("text-anchor", "start")
      .attr("dx", "0.25em")
      .attr("dy", "-0.55em");
  }

  _getPlaceType(place) {
    switch (place.toString()) {
      case "3":
        return I18n.t("gobierto_common.visualizations.country");
      case "2":
        return window.populateData.provinceName;
      case "1":
        return window.populateData.municipalityName;
    }
  }

  _width() {
    return d3.select(this.container).node()
      ? parseInt(d3.select(this.container).style("width"))
      : 0;
  }

  _height() {
    return this.isMobile ? 200 : 250;
  }

  _resize() {
    this.isMobile = window.innerWidth <= 768;

    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

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
      .selectAll(".lines path")
      .attr("d", ([, values]) => this.line(values));

    this.svg
      .selectAll(".lines circle")
      .attr("cx", ([, values]) => this.xScale(new Date(values[0].date)))
      .attr("cy", ([, values]) => this.yScale(values[0].value));

    d3.selectAll(this.container + " .lines-labels div").style(
      "top",
      ([, values]) => this.yScale(values[0].value) + "px"
    );

    this.voronoi.extent([
      [0, 0],
      [this.width, this.height]
    ]);

    this.voronoiGroup
      .selectAll("path")
      .data(this.voronoi.polygons(this.data.flatMap(x => x[1])))
      .attr("d", function(d) {
        return d ? "M" + d.join("L") + "Z" : null;
      });
  }
}
