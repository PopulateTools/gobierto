import * as d3 from 'd3';
import { maxBy, mean, sumBy, uniq } from 'lodash';

export class VisPopulationPyramid {
  constructor(divId, city_id, filter) {
    this.container = divId;

    // Remove previous
    $(`${this.container} svg`).remove();

    this.data = null;
    this.tbiToken = window.populateData.token;
    this.dataUrls = this.getUrls(city_id, filter);

    this.isMobile = window.innerWidth <= 768;
    this.ageBreakpoints = [16, 65];

    // Chart dimensions
    this.gutter = 10;
    this.margin = {
      top: this.gutter * 3.5,
      right: this.gutter,
      bottom: this.gutter * 4,
      left: this.gutter * 4
    };

    const dimensions = this._getDimensions();
    this.width = {
      chart: dimensions.width + this.margin.left + this.margin.right,
      pyramid: dimensions.pyramid.width,
      areas: dimensions.areas.width,
      marks: dimensions.marks.width
    };
    this.height = {
      chart: dimensions.height + this.margin.bottom + this.margin.top,
      pyramid: dimensions.pyramid.height,
      areas: dimensions.areas.height,
      marks: dimensions.marks.height
    };

    // Scales & Ranges
    this.xScaleMale = d3.scaleLinear().range([0, this.width.pyramid / 2]);
    this.xScaleFemale = d3.scaleLinear().range([0, this.width.pyramid / 2]);
    this.xScaleAgeRanges = d3.scaleLinear().range([0, this.width.areas / 3]);
    this.yScale = d3.scaleBand().range([this.height.pyramid, 0]);

    // Create axes
    this.xAxisMale = d3
      .axisBottom()
      .scale(this.xScaleMale)
      .ticks(5)
      .tickFormat(t =>
        t.toLocaleString(I18n.locale, {
          style: "percent",
          minimumFractionDigits: 1
        })
      );
    this.xAxisFemale = d3
      .axisBottom()
      .scale(this.xScaleFemale)
      .ticks(5)
      .tickFormat(t =>
        t.toLocaleString(I18n.locale, {
          style: "percent",
          minimumFractionDigits: 1
        })
      );
    this.yAxis = d3.axisRight().scale(this.yScale);

    // Chart objects
    this.svg = null;
    this.pyramid = null;
    this.areas = null;
    this.marks = null;

    // Create main elements
    this.svg = d3
      .select(this.container)
      .style(
        "padding-bottom",
        `${100 * (this.height.chart / this.width.chart)}%`
      ) // aspect ratio
      .append("svg")
      .attr("preserveAspectRatio", "xMinYMin meet")
      .attr("viewBox", `0 0 ${this.width.chart} ${this.height.chart}`)
      .append("g")
      .attr("class", "chart-container")
      .attr(
        "transform",
        "translate(" + this.margin.left + "," + this.margin.top + ")"
      );

    this.pyramid = this.svg.append("g").attr("class", "pyramid");
    this.areas = this.svg
      .append("g")
      .attr("class", "areas")
      .attr(
        "transform",
        `translate(${this.width.pyramid + 2 * this.gutter},0)`
      );
    this.marks = this.svg
      .append("g")
      .attr("class", "marks")
      .attr(
        "transform",
        `translate(${this.width.pyramid + this.width.areas + this.gutter},0)`
      );

    // Append axes containers
    this.pyramid.append("g").attr("class", "x axis males");
    this.pyramid.append("g").attr("class", "x axis females");
    this.pyramid.append("g").attr("class", "y axis");

    // Static elements
    this._renderStatic();
  }

  getUrls(city_id, filter = 0) {
    // Ensure data to null to force http request
    this.data = null;

    let population = ""
    let unemployed = ""

    switch (filter) {
      case 0:
      default:
        population =
          window.populateData.endpoint +
          `
          WITH maxyear AS (SELECT max(year)
                            FROM poblacion_edad_sexo
                            WHERE place_id = ${city_id})
          SELECT
            CASE
              WHEN sex = 'Hombres' THEN 'V'
              WHEN sex = 'Mujeres' THEN 'M'
            END AS sex,
            age::integer,
            total::integer AS value
          FROM poblacion_edad_sexo
          WHERE place_id = ${city_id}
            AND sex != 'Total'
            AND year =
              (SELECT *
              FROM maxyear)
          ORDER BY age
          `;

        unemployed =
          window.populateData.endpoint +
          `
          WITH maxyear AS
            (SELECT year,
                    month
            FROM paro_personas
            WHERE place_id = ${city_id}
            ORDER BY year DESC, month DESC
            LIMIT 1)
          SELECT sum(value::decimal) AS value
          FROM paro_personas
          WHERE place_id = ${city_id}
            AND year =
              (SELECT year
              FROM maxyear)
            AND month =
              (SELECT month
              FROM maxyear)
          `;
        break;
      case 1:
        population =
          window.populateData.endpoint +
          `
          WITH maxyear AS
            (SELECT max(year)
            FROM poblacion_edad_sexo
            WHERE place_id = ${city_id})
          SELECT
            CASE
              WHEN sex = 'Hombres' THEN 'V'
              WHEN sex = 'Mujeres' THEN 'M'
            END AS sex,
            age::integer,
            SUM(total::integer) AS value
          FROM poblacion_edad_sexo
          WHERE place_id
            BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
            AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
            AND year =
              (SELECT *
              FROM maxyear)
            AND sex != 'Total'
          GROUP BY age, sex
          ORDER BY age
          `;

        unemployed =
          window.populateData.endpoint +
          `
          WITH maxyear AS
            (SELECT year,
                    month
            FROM paro_personas
            WHERE place_id = ${city_id}
            ORDER BY year DESC, month DESC
            LIMIT 1)
          SELECT sum(value::decimal) AS value
          FROM paro_personas
          WHERE place_id
            BETWEEN FLOOR(${city_id}::decimal / 1000) * 1000
            AND (CEIL(${city_id}::decimal / 1000) * 1000) - 1
            AND year =
              (SELECT year
              FROM maxyear)
            AND month =
              (SELECT month
              FROM maxyear)
          `;
        break;
      case 2:
        population =
          window.populateData.endpoint +
          `
          WITH maxyear AS
            (SELECT max(year)
            FROM poblacion_edad_sexo
            WHERE place_id = ${city_id})
          SELECT
            CASE
              WHEN sex = 'Hombres' THEN 'V'
              WHEN sex = 'Mujeres' THEN 'M'
            END AS sex,
            age::integer,
            SUM(total::integer) AS value
          FROM poblacion_edad_sexo
          WHERE year =
              (SELECT *
              FROM maxyear)
            AND sex != 'Total'
          GROUP BY age, sex
          ORDER BY age
          `;

        unemployed =
          window.populateData.endpoint +
          `
          WITH maxyear AS
            (SELECT year,
                    month
            FROM paro_personas
            WHERE place_id = ${city_id}
            ORDER BY year DESC, month DESC
            LIMIT 1)
          SELECT sum(value::decimal) AS value
          FROM paro_personas
          WHERE year =
              (SELECT year
              FROM maxyear)
            AND month =
              (SELECT month
              FROM maxyear)
          `;
        break;
    }

    return {
      population,
      unemployed
    };
  }

  handlePromise(url, opts = {}) {
    return d3.json(url, {
      headers: new Headers({ authorization: "Bearer " + this.tbiToken }),
      ...opts
    });
  }

  getData() {
    const data = this.handlePromise(this.dataUrls.population);
    const unemployed = this.handlePromise(this.dataUrls.unemployed);

    Promise.all([data, unemployed]).then(([jsonPopulation, jsonUnemployed]) => {
      const aux = {
        pyramid: this._transformPyramidData(jsonPopulation.data),
        areas: this._transformAreasData(jsonPopulation.data),
        marks: this._transformMarksData(jsonPopulation.data),
        unemployed: +jsonUnemployed.data[0].value
      };

      this.data = aux;

      this.update(this.data);
    });
  }

  render() {
    if (this.data === null) {
      this.getData();
    } else {
      this.update(this.data);
    }
  }

  update(data) {
    this._updateScales(data);
    this._updateAxes();
    this._updateBars(data.pyramid);
    this._updateAreas(data.areas, data.unemployed);
    this._updateMarks(data.marks);
  }

  _updateScales(data) {
    this.xScaleMale.domain([d3.max(data.pyramid.map(d => d._value)), 0]).nice();

    this.xScaleFemale
      .domain([0, d3.max(data.pyramid.map(d => d._value))])
      .nice();

    this.xScaleAgeRanges
      .domain([d3.max(data.areas.map(d => d.value)), 0])
      .nice();

    this.yScale.domain(uniq(data.pyramid.map(d => d.age)));
  }

  _updateAxes() {
    this.pyramid
      .select(".x.axis.males")
      .transition()
      .duration(500)
      .call(this._xAxisMale.bind(this));

    this.pyramid
      .select(".x.axis.females")
      .transition()
      .duration(500)
      .call(this._xAxisFemale.bind(this));

    this.pyramid
      .select(".y.axis")
      .transition()
      .duration(500)
      .call(this._yAxis.bind(this));
  }

  _updateBars(data) {
    let male = this.pyramid
      .select("g.bars g.males")
      .selectAll("g")
      .data(data.filter(d => d.sex === "V"));

    let female = this.pyramid
      .select("g.bars g.females")
      .selectAll("g")
      .data(data.filter(d => d.sex === "M"));

    // exits
    male.exit().remove();
    female.exit().remove();

    // enters
    let mm = male.enter().append("g");

    mm.append("rect")
      .attr("x", this.width.pyramid / 2) // To animate right to left. Fake value
      .attr("y", d => this.yScale(d.age))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
      .transition()
      .duration(500)
      .attr("width", d => this.width.pyramid / 2 - this.xScaleMale(d._value))
      .attr("x", d => this.xScaleMale(d._value)); // Real value

    mm.append("line")
      .attr("x1", this.width.pyramid / 2) // To animate right to left. Fake value
      .attr("x2", this.width.pyramid / 2)
      .attr("y1", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .attr("y2", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .transition()
      .duration(500)
      .attr("x1", d => this.xScaleMale(d._value));

    let ff = female.enter().append("g");

    ff.append("rect")
      .attr("x", this.width.pyramid / 2)
      .attr("y", d => this.yScale(d.age))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
      .transition()
      .duration(500)
      .attr("width", d => this.xScaleFemale(d._value));

    ff.append("line")
      .attr("x1", this.width.pyramid / 2)
      .attr("x2", this.width.pyramid / 2)
      .attr("y1", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .attr("y2", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .transition()
      .duration(500)
      .attr("x2", d => this.width.pyramid / 2 + this.xScaleFemale(d._value));

    // updates
    male
      .select("rect")
      .transition()
      .duration(500)
      .attr("width", d => this.width.pyramid / 2 - this.xScaleMale(d._value))
      .attr("x", d => this.xScaleMale(d._value)); // Real value

    male
      .select("line")
      .transition()
      .duration(500)
      .attr("x1", d => this.xScaleMale(d._value));

    female
      .select("rect")
      .transition()
      .duration(500)
      .attr("width", d => this.xScaleFemale(d._value));

    female
      .select("line")
      .transition()
      .duration(500)
      .attr("x2", d => this.width.pyramid / 2 + this.xScaleFemale(d._value));
  }

  _updateAreas(data, unemployed) {
    let g = this.areas.selectAll(".range").data(data);

    // enters
    const chartWidth = this.width.areas / 3;

    let ranges = g
      .enter()
      .append("g")
      .attr("class", (d, i) => `range r-${i}`);

    ranges.attr("transform", d => `translate(0, ${this.yScale(d.range[1])})`);

    ranges
      .append("rect")
      .attr("x", chartWidth) // To animate right to left. Fake value
      .attr("height", d => this.yScale(d.range[0]) - this.yScale(d.range[1]))
      .transition()
      .duration(1000)
      .attr("width", d => chartWidth - this.xScaleAgeRanges(d.value))
      .attr("x", d => this.xScaleAgeRanges(d.value)); // Real value

    ranges
      .append("text")
      .attr("x", chartWidth + this.gutter)
      .attr("dy", `${this._pxToEm(1.5 * this.gutter)}em`)
      .attr("class", "title")
      .text(d => `${d.name}: ${this._percent(d.value, this.data.pyramid)}`);

    ranges
      .append("text")
      .attr("x", chartWidth + this.gutter)
      .attr("dy", `${this._pxToEm(4 * this.gutter)}em`)
      .attr("class", "subtitle")
      .text(d => d.info)
      .call(
        this._wrap,
        2 * chartWidth - 4 * this.gutter,
        chartWidth + this.gutter
      );

    // updates
    g.select("rect")
      .transition()
      .duration(1000)
      .attr("width", d => chartWidth - this.xScaleAgeRanges(d.value))
      .attr("x", d => this.xScaleAgeRanges(d.value)); // Real value

    g.select("text.title").text(
      d => `${d.name}: ${this._percent(d.value, this.data.pyramid)}`
    );

    g.select("text.subtitle")
      .text(d => d.info)
      .call(
        this._wrap,
        2 * chartWidth - 4 * this.gutter,
        chartWidth + this.gutter
      );

    // exits
    g.exit().remove();

    /*
     * Ghost Area - area inside the second one (depends on its dimensions)
     *
     */
    let fakeObj = data.find((d, i) => i === 1);
    let fakeData = [Object.assign(fakeObj, { fake: unemployed })];

    let bp = this.ageBreakpoints;
    let yFakeScale = d3
      .scaleLinear()
      .range([0, this.yScale(bp[0]) - this.yScale(bp[1])])
      .domain([0, fakeObj.value]);

    let fakeG = ranges
      .selectAll("rect")
      .filter(d => !Object.prototype.hasOwnProperty.call(d, "fake"))
      .data(fakeData);

    // enters
    let fake = fakeG
      .enter()
      .append("g")
      .attr("class", "r-fake");

    fake.attr(
      "transform",
      d =>
        `translate(0, ${this.yScale(d.range[0]) -
          this.yScale(d.range[1]) -
          yFakeScale(d.fake)})`
    );

    fake
      .append("rect")
      .attr("class", "inner")
      .attr("x", d => this.xScaleAgeRanges(d.value))
      .attr("y", d => yFakeScale(d.fake))
      .attr("width", d => chartWidth - this.xScaleAgeRanges(d.value))
      .attr("height", 0)
      .transition()
      .delay(1000)
      .duration(1000)
      .attr("height", d => yFakeScale(d.fake))
      .attr("y", 0);

    fake
      .append("text")
      .attr("class", "subtitle")
      .attr("opacity", 0)
      .attr("x", chartWidth + this.gutter)
      .attr("dy", `${this._pxToEm(1.5 * this.gutter)}em`)
      .html(
        d =>
          `<tspan class="as-title">${(
            d.fake / d.value
          ).toLocaleString(I18n.locale, { style: "percent" })}</tspan> ${I18n.t(
            "gobierto_common.visualizations.unemployed"
          )}`
      )
      .transition()
      .delay(1000)
      .duration(1000)
      .attr("opacity", 1);

    // updates
    // NOTE: fakeG doesn't work here, we need the g.range updates
    g.select("g.r-fake")
      .transition()
      .delay(1000)
      .duration(1000)
      .attr(
        "transform",
        d =>
          `translate(0, ${this.yScale(d.range[0]) -
            this.yScale(d.range[1]) -
            yFakeScale(d.fake)})`
      );

    g.select("g.r-fake rect")
      .transition()
      .delay(1000)
      .duration(1000)
      .attr("width", d => chartWidth - this.xScaleAgeRanges(d.value))
      .attr("x", d => this.xScaleAgeRanges(d.value)) // Real value
      .attr("height", d => yFakeScale(d.fake))
      .attr("y", 0);

    g.select("g.r-fake text.subtitle").html(
      d =>
        `<tspan class="as-title">${this._percent(
          d.fake,
          this.data.pyramid
        )}</tspan> ${I18n.t("gobierto_common.visualizations.unemployed")}`
    );

    // exits
    fakeG.exit().remove();
  }

  _updateMarks(data) {
    let g = this.marks.selectAll(".mark").data(data);

    // enters
    let marks = g
      .enter()
      .append("g")
      .attr("class", (d, i) => `mark m-${i}`);

    marks
      .transition()
      .duration(1000)
      .attr("transform", d => `translate(0, ${this.yScale(d.value)})`);

    marks
      .append("line")
      .attr("x1", 0)
      .attr("x2", 1.5 * this.gutter);

    marks
      .append("text")
      .attr("x", 2 * this.gutter)
      .attr("dy", ".3em")
      .text(d => d.name)
      .call(this._wrap, this.width.areas - 2 * this.gutter, 2 * this.gutter);

    // updates
    g.transition()
      .duration(500)
      .attr("transform", d => `translate(0, ${this.yScale(d.value)})`);

    g.select("text")
      .text(d => d.name)
      .call(this._wrap, this.width.areas - 2 * this.gutter, 2 * this.gutter);

    // exits
    g.exit().remove();
  }

  _renderStatic() {
    // NOTE: We keep this separate to not create them after every update/resize

    // Pyramid axes
    this.pyramid
      .select(".x.axis.males")
      .attr("transform", `translate(0,${this.height.pyramid})`)
      .call(this._xAxisMale.bind(this));

    this.pyramid
      .select(".x.axis.females")
      .attr(
        "transform",
        `translate(${this.width.pyramid / 2},${this.height.pyramid})`
      )
      .call(this._xAxisFemale.bind(this));

    this.pyramid.select(".y.axis").call(this._yAxis.bind(this));

    // Pyramid titles
    let titles = this.pyramid.append("g").attr("class", "titles");

    titles
      .append("text")
      .attr(
        "transform",
        `translate(${this.width.pyramid / 2 - this.gutter},${-this.margin.top /
          2})`
      )
      .attr("text-anchor", "end")
      .text(I18n.t("gobierto_common.visualizations.men"));

    titles
      .append("text")
      .attr(
        "transform",
        `translate(${this.width.pyramid / 2 + this.gutter},${-this.margin.top /
          2})`
      )
      .attr("text-anchor", "start")
      .text(I18n.t("gobierto_common.visualizations.women"));

    titles
      .append("text")
      .attr("transform", `translate(${-this.gutter},${-this.margin.top / 2})`)
      .attr("text-anchor", "end")
      .text(I18n.t("gobierto_common.visualizations.age"));

    // Pyramid bar-groups
    let g = this.pyramid.append("g").attr("class", "bars");

    g.append("g").attr("class", "males");

    g.append("g").attr("class", "females");

    // Pyramid tooltip
    let focus = g
      .append("g")
      .attr("class", "tooltip")
      .attr("opacity", 0);

    focus.append("text");
  }

  _mousemove(_, d) {
    this.svg
      .select(".tooltip")
      .attr("opacity", 1)
      .select("text")
      .attr("text-anchor", d.sex === "V" ? undefined : "end")
      .attr("x", d.sex === "V" ? 0 : this.width.pyramid)
      .attr("y", this.yScale(95))
      .text(
        `${I18n.t("gobierto_common.visualizations.age")}: ${
          d.age
        } - ${d.value.toLocaleString()} ${
          d.sex === "V"
            ? I18n.t("gobierto_common.visualizations.men")
            : I18n.t("gobierto_common.visualizations.women")
        }`
      );
  }

  _mouseout() {
    this.svg.select(".tooltip").attr("opacity", 0);
  }

  _xAxisMale(g) {
    g.call(this.xAxisMale);

    let s = g.selection ? g.selection() : g; // https://bl.ocks.org/mbostock/4323929
    s.selectAll(".domain").remove();
    s.selectAll(".tick line").remove();
    s.selectAll(".tick:last-child text").remove();
  }

  _xAxisFemale(g) {
    g.call(this.xAxisFemale);

    let s = g.selection ? g.selection() : g; // https://bl.ocks.org/mbostock/4323929
    s.selectAll(".domain").remove();
    s.selectAll(".tick:not(:first-child) line").remove();
    s.selectAll(".tick:first-child line").attr("y1", -this.height.chart);
  }

  _yAxis(g) {
    g.call(
      this.yAxis.tickValues(this.yScale.domain().filter((d, i) => !(i % 10)))
    );

    // https://bl.ocks.org/mbostock/4323929
    let s = g.selection ? g.selection() : g;
    s.selectAll(".domain").remove();
    s.selectAll(".tick line")
      .attr("x1", 0)
      .attr("x2", this.width.pyramid);
    s.selectAll(".tick text").attr("x", -this.margin.left / 4);

    if (s !== g) {
      g.selectAll(".tick line")
        .attrTween("x1", null)
        .attrTween("x2", null);
      g.selectAll(".tick text").attrTween("x", null);
    }
  }

  _transformPyramidData(data) {
    const totalMen = this._total(data.filter(p => p.sex === "V"));
    const totalWomen = this._total(data.filter(p => p.sex === "M"));

    // updates every value with its respective percentage
    return data.map(item => {
      item._value =
        item.sex === "V"
          ? item.value / totalMen
          : item.sex === "M"
          ? item.value / totalWomen
          : 0;
      return item;
    });
  }

  _transformAreasData(data) {
    let bp = this.ageBreakpoints;
    let self = this;

    return [
      {
        name: I18n.t("gobierto_common.visualizations.youth"),
        get info() {
          return I18n.t("gobierto_common.visualizations.youth_info", {
            percent: self._percent(this.value, self.data.pyramid),
            limit: bp[0]
          });
        },
        range: [d3.min(data.map(d => d.age)), bp[0] - 1],
        value: data
          .filter(d => d.age < bp[0])
          .map(d => d.value)
          .reduce((a, b) => a + b)
      },
      {
        name: I18n.t("gobierto_common.visualizations.adults"),
        range: [bp[0], bp[1] - 1],
        value: data
          .filter(d => d.age < bp[1] && d.age >= bp[0])
          .map(d => d.value)
          .reduce((a, b) => a + b)
      },
      {
        name: I18n.t("gobierto_common.visualizations.elderly"),
        get info() {
          return I18n.t("gobierto_common.visualizations.elderly_info", {
            percent: self._percent(this.value, self.data.pyramid),
            limit: bp[1]
          });
        },
        range: [bp[1], d3.max(data.map(d => d.age))],
        value: data
          .filter(d => d.age >= bp[1])
          .map(d => d.value)
          .reduce((a, b) => a + b)
      }
    ];
  }

  _transformMarksData(data) {
    return [
      {
        value: this._mean(data.map(f => f.age)),
        get name() {
          return I18n.t("gobierto_common.visualizations.mean", {
            age: this.value
          });
        }
      },
      {
        value: this._median(data.map(f => f.age)),
        get name() {
          return I18n.t("gobierto_common.visualizations.median", {
            age: this.value
          });
        }
      },
      {
        value: this._mode(data),
        get name() {
          return I18n.t("gobierto_common.visualizations.mode", {
            age: this.value
          });
        }
      }
    ];
  }

  _getDimensions() {
    const width = +(
      d3.select(this.container).node() || document.createElement("div")
    ).getBoundingClientRect().width;
    const ratio = 2;
    const height = width / ratio;

    const pyramid = {
      width: width / 2,
      height
    };
    const areas = {
      width: width / 4,
      height
    };
    const marks = {
      width: width / 4,
      height
    };

    return {
      ratio,
      width,
      height,
      pyramid,
      areas,
      marks
    };
  }

  _total(data) {
    return sumBy(data, "value");
  }

  _mode(data) {
    // It's not required the common mode arithmetical function
    // since the data it's grouped by age, only get the biggest number
    return maxBy(data, "value").age;
  }

  _mean(data) {
    return mean(data);
  }

  _median(data) {
    let array = data.sort();
    if (array.length % 2 === 0) {
      // array with even number elements
      return (array[array.length / 2] + array[array.length / 2 - 1]) / 2;
    } else {
      return array[(array.length - 1) / 2]; // array with odd number elements
    }
  }

  _percent(d, data) {
    return (d / this._total(data)).toLocaleString(I18n.locale, {
      style: "percent"
    });
  }

  _wrap(text, width, start = 0) {
    text.each(function() {
      var text = d3.select(this),
        words = text
          .text()
          .split(/\s+/)
          .reverse(),
        word,
        line = [],
        lineNumber = 0,
        lineHeight = 1.1, // ems
        y = text.attr("y") || 0,
        dy = parseFloat(text.attr("dy")),
        tspan = text
          .text(null)
          .append("tspan")
          .attr("x", start)
          .attr("y", y)
          .attr("dy", dy + "em");


      while ((word = words.pop())) {
        line.push(word);
        tspan.text(line.join(" "));
        if (tspan.node().getComputedTextLength() > width) {
          line.pop();
          tspan.text(line.join(" "));
          line = [word];
          tspan = text
            .append("tspan")
            .attr("x", start)
            .attr("y", y)
            .attr("dy", ++lineNumber * lineHeight + dy + "em")
            .text(word);
        }
      }
    });
  }

  _pxToEm(px, element) {
    element =
      element === null || element === undefined
        ? document.documentElement
        : element;
    var temporaryElement = document.createElement("div");
    temporaryElement.style.setProperty("position", "absolute", "important");
    temporaryElement.style.setProperty("visibility", "hidden", "important");
    temporaryElement.style.setProperty("font-size", "1em", "important");
    element.appendChild(temporaryElement);
    var baseFontSize = parseFloat(getComputedStyle(temporaryElement).fontSize);
    temporaryElement.parentNode.removeChild(temporaryElement);
    return px / baseFontSize;
  }
}
