import { Class, d3 } from "shared"

export var VisPopulationPyramid = Class.extend({
  init: function(divId, city_id, current_year) {
    this.container = divId
    this.currentYear = (current_year !== undefined) ? parseInt(current_year) : null
    this.data = null
    this.tbiToken = window.populateData.token
    this.dataUrl = `${window.populateData.endpoint}/datasets/ds-poblacion-municipal-edad-sexo.json?filter_by_date=${this.currentYear}&filter_by_location_id=${city_id}&except_columns=_id,province_id,location_id,autonomous_region_id`

    this.isMobile = window.innerWidth <= 768

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
    this.xScaleMale = d3.scaleLinear()
    this.xScaleFemale = d3.scaleLinear()
    this.xScaleAgeRanges = d3.scaleLinear()
		this.yScale = d3.scaleBand().padding(0.2)

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
      .append("svg")
      .attr("width", this.width.chart + this.margin.left + this.margin.right)
      .attr("height", this.height.chart + this.margin.top + this.margin.bottom)
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

    // d3.select(window).on(`resize.${this.container}`, this._resize.bind(this))
  },
  getData: function() {
    d3.json(this.dataUrl)
      .header("authorization", "Bearer " + this.tbiToken)
      .get(function(error, jsonData) {
        if (error) throw error

        jsonData.forEach(d => {
          d.age = parseInt(d.age)
          d.value = Number(d.value)
        })

        jsonData.sort((a,b) => a.age - b.age)

        // TODO: completar data
        const aux = {
          pyramid: jsonData,
          areas: this._transformAreasData(jsonData),
          marks: [{
            value: 55,
            get name() {
              return I18n.t('gobierto_observatory.graphics.population_pyramid.mean', { age: this.value })
            }
          }, {
            value: 42,
            get name() {
              return I18n.t('gobierto_observatory.graphics.population_pyramid.median', { age: this.value })
            }
          }, {
            value: 21,
            get name() {
              return I18n.t('gobierto_observatory.graphics.population_pyramid.mode', { age: this.value })
            }
          }]
        }

        this.data = aux

        this.updateRender()
        this._renderBars()
        this._renderAreas()
        this._renderMarks()

      }.bind(this))
  },
  render: function() {
    if (this.data === null) {
      this.getData()
    } else {
      this.updateRender()
    }
  },
  updateRender: function() {
    this.xScaleMale
      .range([0, this.width.pyramid / 2])
      .domain([d3.max(this.data.pyramid.map(d => d.value)), 0])

    this.xScaleFemale
      .range([0, this.width.pyramid / 2])
      .domain([0, d3.max(this.data.pyramid.map(d => d.value))])

    this.xScaleAgeRanges
      .range([0, this.width.areas / 3])
      .domain([d3.max(this.data.areas.map(d => d.value)), 0])

    this.yScale
      .rangeRound([this.height.pyramid, 0])
      .domain(_.uniq(this.data.pyramid.map(d => d.age)))

    this._renderAxis()
  },
  _transformAreasData: function (data, breakpoints) {
    let bp = breakpoints || [18, 65]
    return [
      {
        name: I18n.t('gobierto_observatory.graphics.population_pyramid.youth'),
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
        range: [bp[1], d3.max(data.map(d => d.age))],
        value: data.filter(d => d.age >= bp[1]).map(d => d.value).reduce((a,b)=>a+b)
      }
    ]
  },
  _renderAxis: function() {
    // X axes
    function xAxisMale(g) {
      g.call(this.xAxisMale.scale(this.xScaleMale))
      g.selectAll(".domain").remove()
      g.selectAll(".tick line").remove()
    }

    function xAxisFemale(g) {
      g.call(this.xAxisFemale.scale(this.xScaleFemale))
      g.selectAll(".domain").remove()
      g.selectAll(".tick:not(:first-child) line").remove()
      g.selectAll(".tick:first-child line")
        .attr("y1", -this.gutter)
        .attr("y2", -this.height.pyramid)
    }

    this.pyramid.select(".x.axis.males")
      .attr("transform", `translate(0,${this.height.pyramid - (this.margin.bottom / 2)})`)
      .call(xAxisMale.bind(this))
    this.pyramid.select(".x.axis.females")
      .attr("transform", `translate(${this.width.pyramid / 2},${this.height.pyramid - (this.margin.bottom / 2)})`)
      .call(xAxisFemale.bind(this))

    // Y axis
    function yAxis(g) {
      g.call(this.yAxis
        .scale(this.yScale)
        .tickValues(this.yScale.domain().filter((d,i) => !(i%10))))
      g.selectAll(".domain").remove()
      g.selectAll(".tick line")
        .attr("x1", 0)
        .attr("x2", this.width.pyramid)
      g.selectAll(".tick text")
        .attr("x", -this.margin.left / 4)
    }

    this.pyramid.select(".y.axis").call(yAxis.bind(this))

    // Titles
    let titles = this.pyramid.append("g")
      .attr("class", "titles")

    titles.append("text")
      .attr("transform", `translate(${(this.width.pyramid / 2) - this.gutter},0)`)
      .attr("text-anchor", "end")
      .text(I18n.t('gobierto_observatory.graphics.population_pyramid.men'))

    titles.append("text")
      .attr("transform", `translate(${(this.width.pyramid / 2) + this.gutter},0)`)
      .attr("text-anchor", "start")
      .text(I18n.t('gobierto_observatory.graphics.population_pyramid.women'))

    titles.append("text")
      .attr("text-anchor", "end")
      .text(I18n.t('gobierto_observatory.graphics.population_pyramid.age'))
  },
  _renderBars: function() {
    // We keep this separate to not create them after every resize
    let g = this.pyramid.append("g")
      .attr("class", "bars")

    let male = g.append("g")
      .attr("class", "males")
      .selectAll("rect")
      .data(this.data.pyramid.filter(d => d.sex === "V"))

    let female = g.append("g")
      .attr("class", "females")
      .selectAll("rect")
      .data(this.data.pyramid.filter(d => d.sex === "M"))

    male.exit().remove()
    female.exit().remove()

    male.enter().append("rect")
      .attr("x", this.width.pyramid / 2) // To animate right to left. Fake value
      .attr("y", d => this.yScale(d.age))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
      .transition()
      .duration(500)
      .attr("width", d => (this.width.pyramid / 2) - this.xScaleMale(d.value))
      .attr("x", d => this.xScaleMale(d.value)) // Real value

    female.enter().append("rect")
      .attr("x", this.width.pyramid / 2)
      .attr("y", d => this.yScale(d.age))
      .attr("height", this.yScale.bandwidth())
      .on("mousemove", this._mousemove.bind(this))
      .on("mouseout", this._mouseout.bind(this))
      .transition()
      .duration(500)
      .attr("width", d => this.xScaleFemale(d.value))
  },
  _renderAreas: function() {
    let g = this.areas.selectAll("g")
      .data(this.data.areas)

    g.exit().remove()

    let ranges = g.enter().append("g")
      .attr("class", (d, i) => `range r-${i}`)

    ranges.append("rect")
      .attr("x", this.width.areas / 3) // To animate right to left. Fake value
      .attr("y", d => this.yScale(d.range[1]))
      .attr("height", d => this.yScale(d.range[0]) - this.yScale(d.range[1]))
      .transition()
      .duration(500)
      .attr("width", d => (this.width.areas / 3) - this.xScaleAgeRanges(d.value))
      .attr("x", d => this.xScaleAgeRanges(d.value)) // Real value

    ranges.append("text")
      .attr("x", (this.width.areas / 3) + this.gutter)
      .attr("y", d => this.yScale(d.range[1]) + (1.5 * this.gutter))
      .attr("class", "title")
      .text(d => d.name)

    ranges.append("text")
      .attr("x", (this.width.areas / 3) + this.gutter)
      .attr("y", d => this.yScale(d.range[1]) + (1.5 * this.gutter))
      .attr("dy", "1.5em")
      .attr("class", "subtitle")
      .text("El 23% de la población tiene más de 18 años")
  },
  _renderMarks: function() {
    let g = this.marks.selectAll("g")
      .data(this.data.marks)

    g.exit().remove()

    let marks = g.enter().append("g")
      .attr("class", (d, i) => `mark m-${i}`)

    marks.append("line")
      .attr("x1", 0)
      .attr("x2", 1.5 * this.gutter)
      .attr("y1", d => this.yScale(d.value))
      .attr("y2", d => this.yScale(d.value))

    marks.append("text")
      .attr("x", 2 * this.gutter)
      .attr("y", d => this.yScale(d.value))
      .attr("dy", ".3em")
      .text(d => d.name)
  },
  _mousemove: function() {

  },
  _mouseout: function() {

  },
  _getDimensions: function (opts = {}) {
    let ratio = opts.ratio || 2.5
    let width = opts.width || +d3.select(this.container).node().getBoundingClientRect().width
    let height = opts.height || width / ratio

    let pyramid = {
      width: width / 2,
      height
    }
    let areas = {
      width: width / 3,
      height
    }
    let marks = {
      width: width / 6,
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
  _resize: function() {
    // TODO: COmpletar
    this.width = this._getDimensions().width
    this.height = this._getDimensions().height

    this.updateRender()

    d3.select(`${this.container} svg`)
      .attr("width", this.width + this.margin.left + this.margin.right)
      .attr("height", this.height + this.margin.top + this.margin.bottom)

    this.svg.select(".chart-container")
      .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")")

    // Update bars
    // d3.select("#age_distribution .bars").selectAll("rect")
    //   .attr("x", function(d) { return this.xScale(d.age) }.bind(this))
    //   .attr("y", function(d) { return this.yScale(d.value) }.bind(this))
    //   .attr("width", this.xScale.bandwidth())
    //   .attr("height", function(d) { return this.height - this.yScale(d.value) }.bind(this))
  }
})
