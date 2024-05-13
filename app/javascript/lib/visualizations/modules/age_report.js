import { max } from 'd3-array';
import { axisBottom, axisRight } from 'd3-axis';
import { nest } from 'd3-collection';
import { csv } from 'd3-fetch';
import { format } from 'd3-format';
import { scaleBand, scaleLinear } from 'd3-scale';
import { select, selectAll } from 'd3-selection';
import { accounting } from '../../../lib/shared';
import { uniq } from 'lodash';

const d3 = {
  select,
  selectAll,
  scaleBand,
  scaleLinear,
  axisBottom,
  axisRight,
  csv,
  max,
  format,
  nest
};

export class VisAgeReport {
  constructor(divId, url) {
    this.container = divId;
    this.data = null;
    this.ageGroups = null;
    this.dataUrl = url;
    this.isMobile = window.innerWidth <= 768;

    // Chart dimensions
    this.margin = { top: 25, right: 10, bottom: 25, left: 15 };
    this.width = this._width() - this.margin.left - this.margin.right;
    this.height = this._height() - this.margin.top - this.margin.bottom;

    // Scales & Ranges
    this.xScale = d3.scaleBand().padding(0.3);

    this.yScale = d3.scaleLinear();

    // this.color = d3.scaleSequential(d3.interpolateWarm);

    // Create axes
    this.xAxis = d3.axisBottom();
    this.yAxis = d3.axisRight();

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

  getData() {
    d3.csv(this.dataUrl).then(csvData => {
      // Main dataset
      this.data = csvData;
      this.data.forEach(function(d) {
        d.age = +d.age;
        d.answer = +d.answer;
        d.id = +d.id;
      });

      // d3v5
      //
      var nested = d3
        .nest()
        .key(function(d) {
          return d.id;
        })
        .entries(this.data);

      // d3v6
      //
      // Make an object for each participant
      // var nested = Array.from(
      //   group(this.data, d => d.id),
      //   ([key, values]) => ({
      //     key,
      //     values
      //   })
      // );

      // Gather total participations
      var total = nested.length;

      // d3v5
      //
      this.ageGroups = d3
        .nest()
        .rollup(function(v) {
          return [
            {
              age_group: "16-24",
              response_rate: +accounting.toFixed(
                uniq(
                  v
                    .filter(function(d) {
                      return d.age >= 16 && d.age <= 24;
                    })
                    .map(function(d) {
                      return d.id;
                    })
                ).length / total,
                4
              )
            },
            {
              age_group: "25-34",
              response_rate: +accounting.toFixed(
                uniq(
                  v
                    .filter(function(d) {
                      return d.age >= 25 && d.age <= 34;
                    })
                    .map(function(d) {
                      return d.id;
                    })
                ).length / total,
                4
              )
            },
            {
              age_group: "35-44",
              response_rate: +accounting.toFixed(
                uniq(
                  v
                    .filter(function(d) {
                      return d.age >= 35 && d.age <= 44;
                    })
                    .map(function(d) {
                      return d.id;
                    })
                ).length / total,
                4
              )
            },
            {
              age_group: "45-54",
              response_rate: +accounting.toFixed(
                uniq(
                  v
                    .filter(function(d) {
                      return d.age >= 45 && d.age <= 54;
                    })
                    .map(function(d) {
                      return d.id;
                    })
                ).length / total,
                4
              )
            },
            {
              age_group: "55-64",
              response_rate: +accounting.toFixed(
                uniq(
                  v
                    .filter(function(d) {
                      return d.age >= 55 && d.age <= 64;
                    })
                    .map(function(d) {
                      return d.id;
                    })
                ).length / total,
                4
              )
            },
            {
              age_group: "65+",
              response_rate: +accounting.toFixed(
                uniq(
                  v
                    .filter(function(d) {
                      return d.age >= 65;
                    })
                    .map(function(d) {
                      return d.id;
                    })
                ).length / total,
                4
              )
            }
          ];
        })
        .entries(this.data);

      // d3v6
      //
      // // Assign people to age groups
      // this.ageGroups = rollup(this.data, v => [
      //   {
      //     age_group: "16-24",
      //     response_rate: +accounting.toFixed(
      //       uniq(
      //         v
      //           .filter(function(d) {
      //             return d.age >= 16 && d.age <= 24;
      //           })
      //           .map(function(d) {
      //             return d.id;
      //           })
      //       ).length / total,
      //       4
      //     )
      //   },
      //   {
      //     age_group: "25-34",
      //     response_rate: +accounting.toFixed(
      //       uniq(
      //         v
      //           .filter(function(d) {
      //             return d.age >= 25 && d.age <= 34;
      //           })
      //           .map(function(d) {
      //             return d.id;
      //           })
      //       ).length / total,
      //       4
      //     )
      //   },
      //   {
      //     age_group: "35-44",
      //     response_rate: +accounting.toFixed(
      //       uniq(
      //         v
      //           .filter(function(d) {
      //             return d.age >= 35 && d.age <= 44;
      //           })
      //           .map(function(d) {
      //             return d.id;
      //           })
      //       ).length / total,
      //       4
      //     )
      //   },
      //   {
      //     age_group: "45-54",
      //     response_rate: +accounting.toFixed(
      //       uniq(
      //         v
      //           .filter(function(d) {
      //             return d.age >= 45 && d.age <= 54;
      //           })
      //           .map(function(d) {
      //             return d.id;
      //           })
      //       ).length / total,
      //       4
      //     )
      //   },
      //   {
      //     age_group: "55-64",
      //     response_rate: +accounting.toFixed(
      //       uniq(
      //         v
      //           .filter(function(d) {
      //             return d.age >= 55 && d.age <= 64;
      //           })
      //           .map(function(d) {
      //             return d.id;
      //           })
      //       ).length / total,
      //       4
      //     )
      //   },
      //   {
      //     age_group: "65+",
      //     response_rate: +accounting.toFixed(
      //       uniq(
      //         v
      //           .filter(function(d) {
      //             return d.age >= 65;
      //           })
      //           .map(function(d) {
      //             return d.id;
      //           })
      //       ).length / total,
      //       4
      //     )
      //   }
      // ]);

      // // Convert map to specific array
      // this.ageGroups = Array.from(this.ageGroups, ([key, values]) => ({
      //   key,
      //   values
      // }));

      this.updateRender();
      this._renderBars();
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
      .domain(this.ageGroups.map(d => d.age_group));

    this.yScale
      .rangeRound([this.height, 0])
      .domain([0, d3.max(this.ageGroups, d => d.response_rate)]);

    this._renderAxis();
  }

  _renderBars() {
    // We keep this separate to not create them after every resize
    var barGroup = this.svg
      .append("g")
      .attr("class", "bars")
      .selectAll("rect")
      .data(this.ageGroups)
      .enter();

    var bars = barGroup.append("g").attr(
      "transform",
      function(d) {
        return (
          "translate(" +
          this.xScale(d.age_group) +
          "," +
          this.yScale(d.response_rate) +
          ")"
        );
      }.bind(this)
    );

    bars
      .append("rect")
      .attr("width", this.xScale.bandwidth())
      .attr(
        "height",
        function(d) {
          return this.height - this.yScale(d.response_rate);
        }.bind(this)
      );

    bars
      .append("text")
      .attr("text-anchor", "middle")
      .attr("dy", -5)
      .attr("x", this.xScale.bandwidth() / 2)
      .text(d => d3.format(".0%")(d.response_rate));
  }

  _renderAxis() {
    // X axis
    this.svg
      .select(".x.axis")
      .attr("transform", "translate(0," + this.height + ")");

    this.xAxis.tickPadding(5);
    this.xAxis.tickSize(0, 0);
    this.xAxis.scale(this.xScale);
    this.svg.select(".x.axis").call(this.xAxis);

    // Y axis
    this.svg
      .select(".y.axis")
      .attr("transform", "translate(" + (this.width - 35) + " ,0)");

    this.yAxis.tickSize(-this.width);
    this.yAxis.scale(this.yScale);
    this.yAxis.ticks(3);
    this.yAxis.tickFormat(d3.format(".0%"));
    this.svg.select(".y.axis").call(this.yAxis);

    // Remove the zero
    this.svg
      .selectAll(".y.axis .tick")
      .filter(d => d === 0)
      .remove();
  }

  _width() {
    return d3.select(this.container).node()
      ? parseInt(d3.select(this.container).style("width"))
      : 0;
  }

  _height() {
    return this.isMobile ? 200 : this._width() * 0.25;
  }

  _resize() {
    this.width = this._width();
    this.height = this._height();

    this.updateRender();

    d3.select(this.container + " svg")
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom);

    this.svg
      .select(this.container + " > g")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    // Update bars
    d3.select(this.container + " .bars")
      .selectAll("g")
      .attr(
        "transform",
        function(d) {
          return (
            "translate(" +
            this.xScale(d.age_group) +
            "," +
            this.yScale(d.response_rate) +
            ")"
          );
        }.bind(this)
      );

    d3.select(this.container + " .bars")
      .selectAll("g rect")
      .attr("width", this.xScale.bandwidth())
      .attr(
        "height",
        function(d) {
          return this.height - this.yScale(d.response_rate);
        }.bind(this)
      );

    d3.select(this.container + " .bars")
      .selectAll("g text")
      .attr("x", this.xScale.bandwidth() / 2);
  }
}
