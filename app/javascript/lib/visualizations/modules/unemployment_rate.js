import { group, max, merge } from "d3-array";
import { axisBottom, axisLeft } from "d3-axis";
import { json } from "d3-fetch";
import { format } from "d3-format";
import { scaleLinear, scaleOrdinal, scaleTime } from "d3-scale";
import { select, selectAll } from "d3-selection";
import { line } from "d3-shape";
import { timeParse } from "d3-time-format";
import { voronoi } from "d3-voronoi";

const d3 = {
  timeParse,
  format,
  select,
  scaleTime,
  scaleLinear,
  scaleOrdinal,
  axisBottom,
  axisLeft,
  json,
  max,
  line,
  merge,
  selectAll,
  voronoi
};

export class VisUnemploymentRate {
  constructor(divId, city_id, ccaa_id) {
    this.container = divId;
    this.data = null;
    this.tbiToken = window.populateData.token;
    this.placeUrl =
      window.populateData.endpoint +
      "/datasets/ds-tasa-paro-municipal.json?sort_asc_by=date&filter_by_location_id=" +
      city_id;
    this.autonomousRegionUrl =
      window.populateData.endpoint +
      "/datasets/ds-epa-tasa-paro-autonomica-trimestral.json?sort_asc_by=date&filter_by_location_id=" +
      ccaa_id;
    this.countryUrl =
      window.populateData.endpoint +
      "/datasets/ds-epa-tasa-paro-nacional-trimestral.json?sort_asc_by=date";
    this.parseTime = d3.timeParse("%Y-%m");
    this.valueFormat = d3.format(".1%");
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
    this.chart = null;

    // Create main elements
    this.svg = d3
      .select(this.container)
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
    return json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  getData() {
    var place = this.handlePromise(this.placeUrl);
    var autonomousRegion = this.handlePromise(this.autonomousRegionUrl);
    var country = this.handlePromise(this.countryUrl);

    Promise.all([place, autonomousRegion, country]).then(
      ([jsonPlace, jsonAutonomousRegion, jsonCountry]) => {
        jsonPlace.forEach(
          function(d) {
            d.location_type = "place";
            d.date = this.parseTime(d.date);
          }.bind(this)
        );

        jsonAutonomousRegion.forEach(
          function(d) {
            d.location_type = "autonomous_region";
            d.date = this.parseTime(d.date.slice(0, 7));
          }.bind(this)
        );

        jsonCountry.forEach(
          function(d) {
            d.location_type = "country";
            d.date = this.parseTime(d.date.slice(0, 7));
          }.bind(this)
        );

        this.data = jsonPlace.concat(jsonAutonomousRegion, jsonCountry);

        this.nest = Array.from(
          group(this.data, d => d.location_type),
          ([key, values]) => ({
            key,
            values
          })
        );

        this.updateRender();
        this._renderLines();
        this._renderVoronoi();
      }
    );
  }

  render() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  }

  updateRender() {
    this.xScale.rangeRound([0, this.width]).domain([
      this.parseTime("2011-01"),
      d3.max(this.data, function(d) {
        return d.date;
      })
    ]);

    this.yScale.rangeRound([this.height, 0]).domain([
      0,
      d3.max(this.data, function(d) {
        return d.value;
      })
    ]);

    this.color
      .domain(["place", "autonomous_region", "country"])
      .range(["#F6B128", "#F39D96", "#007382"]);

    this._renderAxis();
  }

  _renderLines() {
    this.line = d3
      .line()
      .x(
        function(d) {
          return this.xScale(d.date);
        }.bind(this)
      )
      .y(
        function(d) {
          return this.yScale(d.value);
        }.bind(this)
      );
    // .curve(d3.curveCatmullRom.alpha(0.5));

    var lines = this.svg
      .append("g")
      .attr("class", "lines")
      .selectAll("path")
      .data(this.nest, function(d) {
        return d.key;
      })
      .enter();

    var linesGroup = lines.append("g").attr("class", "line");

    linesGroup
      .append("path")
      .attr(
        "d",
        function(d) {
          d.line = this;
          return this.line(d.values);
        }.bind(this)
      )
      .attr(
        "stroke",
        function(d) {
          return this.color(d.key);
        }.bind(this)
      );

    linesGroup
      .append("circle")
      .attr(
        "cx",
        function(d) {
          return this.xScale(
            d.values
              .map(function(d) {
                return d.date;
              })
              .slice(-1)[0]
          );
        }.bind(this)
      )
      .attr(
        "cy",
        function(d) {
          return this.yScale(
            d.values
              .map(function(d) {
                return d.value;
              })
              .slice(-1)[0]
          );
        }.bind(this)
      )
      .attr("r", 5)
      .attr(
        "fill",
        function(d) {
          return this.color(d.key);
        }.bind(this)
      );

    var linesText = d3
      .select(this.container)
      .append("div")
      .attr("class", "lines-labels")
      .selectAll("p")
      .data(this.nest, function(d) {
        return d.key;
      })
      .enter();

    linesText
      .append("div")
      .style("right", "10px")
      .style(
        "top",
        function(d) {
          return (
            this.yScale(
              d.values
                .map(function(d) {
                  return d.value;
                })
                .slice(-1)[0]
            ) + "px"
          );
        }.bind(this)
      )
      .text(
        function(d) {
          return this._getPlaceType(d.key);
        }.bind(this)
      );
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

    this.voronoi = d3
      .voronoi()
      .x(
        function(d) {
          return this.xScale(d.date);
        }.bind(this)
      )
      .y(
        function(d) {
          return this.yScale(d.value);
        }.bind(this)
      )
      .extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup = this.svg.append("g").attr("class", "voronoi");

    this.voronoiGroup
      .selectAll("path")
      .data(
        this.voronoi.polygons(
          d3.merge(
            this.nest.map(function(d) {
              return d.values;
            })
          )
        )
      )
      .enter()
      .append("path")
      .attr("d", function(d) {
        return d ? "M" + d.join("L") + "Z" : null;
      })
      .on("mouseover", this._mouseover.bind(this))
      .on("mouseout", this._mouseout.bind(this));
  }

  // WARNING: replace arguments in d3v6
  _mouseover(d) {
    this.focus
      .select("circle")
      .attr("stroke", this.color(d.data.location_type));

    this.focus.attr(
      "transform",
      "translate(" +
        this.xScale(d.data.date) +
        "," +
        this.yScale(d.data.value) +
        ")"
    );
    this.focus
      .select("text")
      .attr(
        "text-anchor",
        d.data.date >= this.parseTime("2014-01") ? "end" : "start"
      );
    this.focus.select("tspan").text(
      `${this._getPlaceType(d.data.location_type)}: ${
        d.data.value
      }% (${d.data.date.toLocaleString(I18n.locale, {
        month: "short"
      })} ${d.data.date.getFullYear()})`
    );
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
      .tickFormat(function(d) {
        return d + "%";
      })
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
    switch (place) {
      case "country":
        return I18n.t("gobierto_common.visualizations.country");
      case "autonomous_region":
        return window.populateData.ccaaName;
      case "place":
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

    this.svg.selectAll(".lines path").attr(
      "d",
      function(d) {
        d.line = this;
        return this.line(d.values);
      }.bind(this)
    );

    this.svg
      .selectAll(".lines circle")
      .attr(
        "cx",
        function(d) {
          return this.xScale(
            d.values
              .map(function(d) {
                return d.date;
              })
              .slice(-1)[0]
          );
        }.bind(this)
      )
      .attr(
        "cy",
        function(d) {
          return this.yScale(
            d.values
              .map(function(d) {
                return d.value;
              })
              .slice(-1)[0]
          );
        }.bind(this)
      );

    d3.selectAll(this.container + " .lines-labels div").style(
      "top",
      function(d) {
        return (
          this.yScale(
            d.values
              .map(function(d) {
                return d.value;
              })
              .slice(-1)[0]
          ) + "px"
        );
      }.bind(this)
    );

    this.voronoi.extent([[0, 0], [this.width, this.height]]);

    this.voronoiGroup
      .selectAll("path")
      .data(
        this.voronoi.polygons(
          d3.merge(
            this.nest.map(function(d) {
              return d.values;
            })
          )
        )
      )
      .attr("d", function(d) {
        return d ? "M" + d.join("L") + "Z" : null;
      });
  }
}
