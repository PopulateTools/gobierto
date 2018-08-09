import { Class, d3, URLParams } from "shared"

export var VisPopulationPyramid = Class.extend({
  init: function(divId, city_id, current_year, filter) {
    this.container = divId

    // Remove previous
    $(`${this.container} svg`).remove()

    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null
    this.data = null
    this.tbiToken = window.populateData.token
    this.dataUrls = this.getUrls(city_id, filter)

    this.isMobile = window.innerWidth <= 768
    this.ageBreakpoints = [16, 65]

    // Chart dimensions
    this.gutter = 10
    this.margin = {
      top: this.gutter * 1.5,
      right: this.gutter,
      bottom: this.gutter * 2.5,
      left: this.gutter * 4
    }
    this.width = {
      chart: this._getDimensions().width,
      pyramid: this._getDimensions().pyramid.width,
      areas: this._getDimensions().areas.width,
      marks: this._getDimensions().marks.width
    }
    this.height = {
      chart: this._getDimensions().height,
      pyramid: this._getDimensions().pyramid.height,
      areas: this._getDimensions().areas.height,
      marks: this._getDimensions().marks.height
    }

    // Scales & Ranges
    this.xScaleMale = d3.scaleLinear().range([0, this.width.pyramid / 2])
    this.xScaleFemale = d3.scaleLinear().range([0, this.width.pyramid / 2])
    this.xScaleAgeRanges = d3.scaleLinear().range([0, this.width.areas / 3])
		this.yScale = d3.scaleBand().rangeRound([this.height.pyramid, 0])

    // Create axes
    this.xAxisMale = d3.axisBottom()
    this.xAxisFemale = d3.axisBottom()
    this.yAxis = d3.axisRight()

    // Chart objects
    this.svg = null
    this.pyramid = null
    this.areas = null
    this.marks = null

    // Create main elements
    this.svg = d3.select(this.container)
      .style("padding-bottom", `${100 / this._getDimensions().ratio}%`) // aspect ratio
      .append("svg")
      .attr("preserveAspectRatio", "xMinYMin meet")
      .attr("viewBox", `0 0 ${this.width.chart + this.margin.left + this.margin.right} ${this.height.chart + this.margin.top + this.margin.bottom}`)
      .append("g")
      .attr("class", "chart-container")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")

    this.pyramid = this.svg.append("g").attr("class", "pyramid")
    this.areas = this.svg.append("g")
      .attr("class", "areas")
      .attr("transform", `translate(${this.width.pyramid + (2 * this.gutter)},0)`)
    this.marks = this.svg.append("g")
      .attr("class", "marks")
      .attr("transform", `translate(${this.width.pyramid + this.width.areas + this.gutter},0)`)

    // Append axes containers
    this.pyramid.append("g").attr("class","x axis males")
    this.pyramid.append("g").attr("class","x axis females")
    this.pyramid.append("g").attr("class","y axis")

    // Static elements
    this._renderStatic()
  },
  getUrls: function(city_id, filter = 0) {
    // Ensure data to null to force http request
    this.data = null

    // Original endpoints
    const endpoints = {
      population: {
        endpoint: `${window.populateData.endpoint}/datasets/ds-poblacion-municipal-edad-sexo.json`,
        params: {

        }
      },
      unemployed: {
        endpoint: `${window.populateData.endpoint}/datasets/ds-personas-paradas-municipio.json`,
        params: {
          except_columns: "_id,province_id,location_id,autonomous_region_id"
        }
      }
    }

    // Dynamic filters
    for (var endpoint in endpoints) {
      if (endpoints.hasOwnProperty(endpoint)) {
        let param = endpoints[endpoint].params || {}

        if (this.currentYear) {
          param = Object.assign(param, {
            filter_by_date: this.currentYear
          })
        }

        switch (filter) {
          case 0:
          default:
            param = Object.assign(param, {
              except_columns: "_id,province_id,location_id,autonomous_region_id",
              filter_by_location_id: city_id
            })
            break;
          case 1:
            if (endpoint === "population") {
              param = Object.assign(param, {
                group_by: "age,sex"
              })
            } else if (endpoint === "unemployed") {
              param = Object.assign(param, {
                except_columns: "_id,province_id,location_id,autonomous_region_id"
              })
            }

            param = Object.assign(param, {
              filter_by_autonomous_region_id: city_id,
            })

            break;
          case 2:
            if (endpoint === "population") {
              param = Object.assign(param, {
                group_by: "age,sex"
              })
            }
            break;
        }

        endpoints[endpoint].params = param
      }
    }

    const population = URLParams(endpoints.population)
    const unemployed = URLParams(endpoints.unemployed)

    return {
      population,
      unemployed
    }
  },
  getData: function() {
    let unemployed = d3.json(this.dataUrls.unemployed)
      .header("authorization", "Bearer " + this.tbiToken)

    let population = d3.json(this.dataUrls.population)
      .header("authorization", "Bearer " + this.tbiToken)

    return d3.queue()
      .defer(population.get)
      .defer(unemployed.get)
      .await(function(error, jsonPopulation, jsonUnemployed) {
        if (error) throw error

        jsonPopulation.forEach(d => {
          d.age = parseInt(d.age)
          d.value = Number(d.value)
        })

        jsonPopulation.sort((a,b) => a.age - b.age)

        const aux = {
          pyramid: this._transformPyramidData(jsonPopulation),
          areas: this._transformAreasData(jsonPopulation),
          marks: this._transformMarksData(jsonPopulation),
          unemployed: jsonUnemployed.map(v=>v.value).reduce((a,b)=>a+b)
        }

        this.data = aux
        this.update(this.data)

        // DEBUG
        window.datos = this.data
      }.bind(this))
  },
  render: function() {
    if (this.data === null) {
      this.getData()
    } else {
      this.update(this.data)
    }
  },
  update: function(data) {
    this._updateScales(data)
    this._updateAxes()
    this._updateBars(data.pyramid)
    this._updateMarks(data.marks)
  },
  _updateScales: function (data) {
    this.xScaleMale
      .domain([d3.max(data.pyramid.map(d => d._value)), 0]).nice()

    this.xScaleFemale
      .domain([0, d3.max(data.pyramid.map(d => d._value))]).nice()

    this.xScaleAgeRanges
      .domain([d3.max(data.areas.map(d => d.value)), 0]).nice()

    this.yScale
      .domain(_.uniq(data.pyramid.map(d => d.age)))
  },
  _updateAxes: function () {
    this.pyramid.selectAll(".x.axis.males")
      .transition().duration(500)
      .call(this._xAxisMale.bind(this))

    this.pyramid.selectAll(".x.axis.females")
      .transition().duration(500)
      .call(this._xAxisFemale.bind(this))

    this.pyramid.selectAll(".y.axis")
      .transition().duration(500)
      .call(this._yAxis.bind(this))
  },
  _updateBars: function (data) {
    // USING UPDATE PATTERN
    let male = this.pyramid.select("g.bars g.males")
      .selectAll("g")
      .data(data.filter(d => d.sex === "V"))

    let female = this.pyramid.select("g.bars g.females")
      .selectAll("g")
      .data(data.filter(d => d.sex === "M"))

    // enters
    let mm = male.enter().append("g")

    mm.append("rect")
      .attr("x", this.width.pyramid / 2) // To animate right to left. Fake value
      .attr("y", d => this.yScale(d.age))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
      .transition()
      .duration(500)
      .attr("width", d => (this.width.pyramid / 2) - this.xScaleMale(d._value))
      .attr("x", d => this.xScaleMale(d._value)) // Real value

    mm.append("line")
      .attr("x1", this.width.pyramid / 2) // To animate right to left. Fake value
      .attr("x2", this.width.pyramid / 2)
      .attr("y1", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .attr("y2", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .transition()
      .duration(500)
      .attr("x1", d => this.xScaleMale(d._value))

    let ff = female.enter().append("g")

    ff.append("rect")
      .attr("x", this.width.pyramid / 2)
      .attr("y", d => this.yScale(d.age))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
      .transition()
      .duration(500)
      .attr("width", d => this.xScaleFemale(d._value))

    ff.append("line")
      .attr("x1", this.width.pyramid / 2)
      .attr("x2", this.width.pyramid / 2)
      .attr("y1", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .attr("y2", d => this.yScale(d.age) + this.yScale.bandwidth() - 1)
      .transition()
      .duration(500)
      .attr("x2", d => this.width.pyramid / 2 + this.xScaleFemale(d._value))

    // updates
    male.select("rect")
      .transition()
      .duration(500)
      .attr("width", d => (this.width.pyramid / 2) - this.xScaleMale(d._value))
      .attr("x", d => this.xScaleMale(d._value)) // Real value

    male.select("line")
      .transition()
      .duration(500)
      .attr("x1", d => this.xScaleMale(d._value))

    female.select("rect")
      .transition()
      .duration(500)
      .attr("width", d => this.xScaleFemale(d._value))

    female.select("line")
      .transition()
      .duration(500)
      .attr("x2", d => this.width.pyramid / 2 + this.xScaleFemale(d._value))

    // exits
    male.exit().remove()
    female.exit().remove()
  },
  _updateAreas: function () {
    // USING UPDATE PATTERN
  },
  _updateMarks: function (data) {
    // USING UPDATE PATTERN
    let g = this.marks.selectAll(".mark")
      .data(data)

    // enters
    let marks = g.enter().append("g")
      .attr("class", (d, i) => `mark m-${i}`)

    marks
      .transition()
      .duration(1000)
      .attr("transform", d => `translate(0, ${this.yScale(d.value)})`)

    marks.append("line")
      .attr("x1", 0)
      .attr("x2", 1.5 * this.gutter)

    marks.append("text")
      .attr("x", 2 * this.gutter)
      .attr("dy", ".3em")
      .text(d => d.name)
      .call(this._wrap, this.width.areas - (2 * this.gutter), 2 * this.gutter)

    // updates
    g.transition()
      .duration(500)
      .attr("transform", d =>`translate(0, ${this.yScale(d.value)})`)

    g.select("text")
      .text(d => d.name)
      .call(this._wrap, this.width.areas - (2 * this.gutter), 2 * this.gutter)

    // exits
    g.exit().remove()
  },
  _renderStatic: function () {
    // NOTE: We keep this separate to not create them after every update/resize

    // Pyramid axes
    this.pyramid.select(".x.axis.males")
      .attr("transform", `translate(0,${this.height.pyramid - this.margin.bottom})`)
      .call(this._xAxisMale.bind(this))

    this.pyramid.select(".x.axis.females")
      .attr("transform", `translate(${this.width.pyramid / 2},${this.height.pyramid - this.margin.bottom})`)
      .call(this._xAxisFemale.bind(this))

    this.pyramid.select(".y.axis").call(this._yAxis.bind(this))

    // Pyramid titles
    let titles = this.pyramid.append("g")
      .attr("class", "titles")

    titles.append("text")
      .attr("transform", `translate(${(this.width.pyramid / 2) - this.gutter},${this.gutter})`)
      .attr("text-anchor", "end")
      .text(I18n.t('gobierto_observatory.graphics.population_pyramid.men'))

    titles.append("text")
      .attr("transform", `translate(${(this.width.pyramid / 2) + this.gutter},${this.gutter})`)
      .attr("text-anchor", "start")
      .text(I18n.t('gobierto_observatory.graphics.population_pyramid.women'))

    titles.append("text")
      .attr("transform", `translate(0,${this.gutter})`)
      .attr("text-anchor", "end")
      .text(I18n.t('gobierto_observatory.graphics.population_pyramid.age'))

    // Pyramid bar-groups
    let g = this.pyramid.append("g")
      .attr("class", "bars")

    g.append("g")
      .attr("class", "males")

    g.append("g")
      .attr("class", "females")

    // Pyramid tooltip
    let focus = g.append("g")
      .attr("class", "tooltip")
      .attr("opacity", 0)

    focus.append("text")
  },
  _renderAreas: function() {
    let g = this.areas.selectAll("g")
      .data(this.data.areas)

    g.exit().remove()

    let ranges = g.enter().append("g")
      .attr("class", (d, i) => `range r-${i}`)

    let chartWidth = this.width.areas / 3

    ranges.append("rect")
      .attr("x", chartWidth) // To animate right to left. Fake value
      .attr("y", d => this.yScale(d.range[1]))
      .attr("height", d => this.yScale(d.range[0]) - this.yScale(d.range[1]))
      .transition()
      .delay(200)
      .duration(500)
      .attr("width", d => chartWidth - this.xScaleAgeRanges(d.value))
      .attr("x", d => this.xScaleAgeRanges(d.value)) // Real value

    ranges.append("text")
      .attr("x", chartWidth + this.gutter)
      .attr("y", d => this.yScale(d.range[1]) + (1.5 * this.gutter))
      .attr("class", "title")
      .text(d => `${d.name}: ${this._math.percent(d.value, this.data.pyramid)}`)

    ranges.append("text")
      .attr("x", chartWidth + this.gutter)
      .attr("y", d => this.yScale(d.range[1]) + (1.5 * this.gutter))
      .attr("dy", "1.5em")
      .attr("class", "subtitle")
      .text(d => d.info)
      .call(this._wrap, (2 * chartWidth) - (4 * this.gutter), chartWidth + this.gutter)

    // ghost scale
    let fakeObj = this.data.areas.find((d, i) => i === 1)
    let fakeData = [Object.assign(fakeObj, { fake: this.data.unemployed })]
    let bp = this.ageBreakpoints
    let yFakeScale = d3.scaleLinear()
      .range([0, this.yScale(bp[0]) - this.yScale(bp[1])])
      .domain([0, fakeObj.value])

    let fakeG = ranges.selectAll("rect")
      .filter(d => !d.hasOwnProperty('fake'))
      .data(fakeData)

    fakeG.exit().remove()

    let fake = fakeG.enter().append("g")

    fake.append("rect")
      .attr("class", "inner")
      .attr("x", d => this.xScaleAgeRanges(d.value))
      .attr("y", d => this.yScale(d.range[0])) // Fake value
      .attr("width", d => chartWidth - this.xScaleAgeRanges(d.value))
      .attr("height", 0)
      .transition()
      .delay(500)
      .duration(500)
      .attr("height", d => yFakeScale(d.fake))
      .attr("y", d => this.yScale(d.range[0]) - yFakeScale(d.fake)) // real value

    fake.append("text")
      .attr("class", "subtitle")
      .attr("opacity", 0)
      .attr("x", chartWidth + this.gutter)
      .attr("y", d => this.yScale(d.range[0]) + (1.5 * this.gutter))
      .html(d => `<tspan class="as-title">${(d.fake / d.value).toLocaleString(I18n.locale, { style: 'percent' })}</tspan> ${I18n.t('gobierto_observatory.graphics.population_pyramid.unemployed')}`)
      .transition()
      .delay(500)
      .duration(500)
      .attr("opacity", 1)
      .attr("y", d => this.yScale(d.range[0]) - yFakeScale(d.fake) + (1.5 * this.gutter))
  },
  _mousemove: function(d) {
    this.svg.select(".tooltip")
      .attr("opacity", 1)
      .select("text")
      .attr("text-anchor", (d.sex === "V") ? undefined : "end")
      .attr("x", (d.sex === "V") ? 0 : this.width.pyramid)
      .attr("y", this.yScale(95))
      .text(`${I18n.t('gobierto_observatory.graphics.population_pyramid.age')}: ${d.age} - ${d.value.toLocaleString()} ${(d.sex === "V") ? I18n.t('gobierto_observatory.graphics.population_pyramid.men') : I18n.t('gobierto_observatory.graphics.population_pyramid.women')}`);
  },
  _mouseout: function() {
    this.svg.select(".tooltip")
      .attr("opacity", 0)
  },
  _xAxisMale: function (g) {
    g.call(this.xAxisMale
      .scale(this.xScaleMale)
      .ticks(5)
      .tickFormat(t => t.toLocaleString(I18n.locale, { style: 'percent', minimumFractionDigits: 1 })))
    g.selectAll(".domain").remove()
    g.selectAll(".tick line").remove()
    g.selectAll(".tick:last-child text").remove()
  },
  _xAxisFemale: function (g) {
    g.call(this.xAxisFemale
      .scale(this.xScaleFemale)
      .ticks(5)
      .tickFormat(t => t.toLocaleString(I18n.locale, { style: 'percent', minimumFractionDigits: 1 })))
    g.selectAll(".domain").remove()
    g.selectAll(".tick:not(:first-child) line").remove()
    g.selectAll(".tick:first-child line")
      .attr("y1", -this.gutter)
      .attr("y2", -this.height.pyramid)
  },
  _yAxis: function (g) {
    g.call(this.yAxis
      .scale(this.yScale)
      .tickValues(this.yScale.domain().filter((d,i) => !(i%10))))
    g.selectAll(".domain").remove()
    g.selectAll(".tick line")
      .attr("x1", 0)
      .attr("x2", this.width.pyramid)
    g.selectAll(".tick text")
      .attr("x", -this.margin.left / 4)
  },
  _transformPyramidData: function(data) {
    const totalMen = this._math.total(data.filter(p => p.sex === "V"))
    const totalWomen = this._math.total(data.filter(p => p.sex === "M"))
    // updates every value with its respective percentage
    return data.map((item) => {
      item._value = (item.sex === "V") ? (item.value / totalMen) : (item.sex === "M") ? (item.value / totalWomen) : 0
      return item
    })
  },
  _transformAreasData: function(data) {
    let bp = this.ageBreakpoints
    let self = this
    return [
      {
        name: I18n.t('gobierto_observatory.graphics.population_pyramid.youth'),
        get info() {
          return I18n.t('gobierto_observatory.graphics.population_pyramid.youth_info', { percent: self._math.percent(this.value, self.data.pyramid), limit: bp[0] })
        },
        range: [d3.min(data.map(d => d.age)), bp[0] - 1],
        value: data.filter(d => d.age < bp[0]).map(d => d.value).reduce((a,b)=>a+b)
      },
      {
        name: I18n.t('gobierto_observatory.graphics.population_pyramid.adults'),
        range: [bp[0], bp[1] - 1],
        value: data.filter(d => d.age < bp[1] && d.age >= bp[0]).map(d => d.value).reduce((a,b)=>a+b)
      },
      {
        name: I18n.t('gobierto_observatory.graphics.population_pyramid.elderly'),
        get info() {
          return I18n.t('gobierto_observatory.graphics.population_pyramid.elderly_info', { percent: self._math.percent(this.value, self.data.pyramid), limit: bp[1] })
        },
        range: [bp[1], d3.max(data.map(d => d.age))],
        value: data.filter(d => d.age >= bp[1]).map(d => d.value).reduce((a,b)=>a+b)
      }
    ]
  },
  _transformMarksData: function(data) {
    return [{
      value: this._math.mean(data.map(f => f.age)),
      get name() {
        return I18n.t('gobierto_observatory.graphics.population_pyramid.mean', { age: this.value })
      }
    }, {
      value: this._math.median(data.map(f => f.age)),
      get name() {
        return I18n.t('gobierto_observatory.graphics.population_pyramid.median', { age: this.value })
      }
    }, {
      value: this._math.mode(data),
      get name() {
        return I18n.t('gobierto_observatory.graphics.population_pyramid.mode', { age: this.value })
      }
    }]
  },
  _getDimensions: function(opts = {}) {
    let width = opts.width || +d3.select(this.container).node().getBoundingClientRect().width
    let ratio = opts.ratio || 2.5
    let height = opts.height || width / ratio

    let pyramid = {
      width: width / 2,
      height
    }
    let areas = {
      width: width / 4,
      height
    }
    let marks = {
      width: width / 4,
      height
    }

    return {
      ratio,
      width,
      height,
      pyramid,
      areas,
      marks
    }
  },
  _math: {
    total(data) {
      return _.sumBy(data, 'value')
    },
    mode(data) {
      // It's not required the common mode arithmetical function
      // since the data it's grouped by age, only get the biggest number
      return _.maxBy(data, 'value').age
    },
    mean(data) {
      return _.mean(data)
    },
    median(data) {
      let array = data.sort()
      if (array.length % 2 === 0) { // array with even number elements
        return (array[array.length / 2] + array[(array.length / 2) - 1]) / 2;
      } else {
        return array[(array.length - 1) / 2]; // array with odd number elements
      }
    },
    percent(d, data) {
      return (d / this.total(data)).toLocaleString(I18n.locale, { style: 'percent' })
    }
  },
  _wrap: function(text, width, start = 0) {
    text.each(function() {
      var text = d3.select(this),
        words = text.text().split(/\s+/).reverse(),
        word,
        line = [],
        lineNumber = 0,
        lineHeight = 1.1, // ems
        y = text.attr("y"),
        dy = parseFloat(text.attr("dy")),
        tspan = text.text(null).append("tspan").attr("x", start).attr("y", y).attr("dy", dy + "em");

      /* eslint-disable no-cond-assign */
      while (word = words.pop()) {
        line.push(word);
        tspan.text(line.join(" "));
        if (tspan.node().getComputedTextLength() > width) {
          line.pop();
          tspan.text(line.join(" "));
          line = [word];
          tspan = text.append("tspan").attr("x", start).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
        }
      }
    });
  },
})
