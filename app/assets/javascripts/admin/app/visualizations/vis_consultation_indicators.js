'use strict';

var VisIndicators = Class.extend({
  init: function(divId) {
    this.container = divId;
    this.data = null;
    this.total = null;
    this.genderRatio = null;
    this.eqRatio = null;
    this.avgAge = null;
    this.places = null;
    this.table = null;
    this.dataUrl = '/consultation-1-responses-2017-03-15.csv';
    
    console.log('wadus wadus');
  },
  getData: function() {
    d3.csv(this.dataUrl)
      .get(function(error, csvData) {
        if (error) throw error;
        
        // Main dataset
        this.data = csvData;
        this.data.forEach(function(d) {
          d.age = +d.age
          d.answer = +d.answer
          d.id = +d.id
        });
        
        // Make an object for each participant
        var totalNest = d3.nest()
          .key(function(d) { return d.id; })
          .entries(this.data);
          
        totalNest.forEach(function(d) {
          d.age = d.values[0].age;
          d.location = d.values[0].location
        });
        
        // TOTAL RESPONSES
        this.total = totalNest.length;
        
        // GENDER RATIO
        var ratioNest = d3.nest()
          .key(function(d) { return d.gender; })
          .key(function(d) { return d.id; })
          .entries(this.data);

        this.genderRatio = [ratioNest[0].values.length / this.total, ratioNest[1].values.length / this.total];
        
        // EQ / DEFICIT RATIO
        var eqNest = d3.nest()
          .key(function(d) { return d.id; })
          .rollup(function(v) { return d3.sum(v, function(d) { return d.answer; }) })
          .entries(this.data);
          
        this.eqRatio = [
          eqNest.filter(function(d) { return d.value < 0; }).length / this.total,
          eqNest.filter(function(d) { return d.value === 0; }).length / this.total,
          eqNest.filter(function(d) { return d.value > 0; }).length / this.total
        ];
        
        // AVERAGE AGE
        this.avgAge = d3.mean(totalNest, function(d) { return d.age; });
        
        // PLACES COUNT
        var placesNest = d3.nest()
          .key(function(d) { return d.location; })
          .key(function(d) { return d.id; })
          .rollup(function(v) { return v.length; })
          .entries(this.data);
          
        this.places = placesNest.map(function(d) {
          return {
            location: d.key,
            responses: d.values.length / this.total
          }
        }.bind(this));
        
        this.places.sort(function(a, b) { return b.responses - a.responses; });
        
        // GET QUESTIONS SUMMARY
        this.table = d3.nest()
          .key(function(d) { return d.question; })
          .key(function(d) { return d.answer; })
          .rollup(function(d) { return d.length / this.total; }.bind(this))
          .entries(this.data)
        
        console.log(this.table);
        
        this.updateRender();
      }.bind(this));
  },
  render: function() {
    if (this.data === null) {
      this.getData();
    } else {
      this.updateRender();
    }
  },
  updateRender: function(callback) {
    var format = d3.format('.0%');
    
    // TOTAL PARTICIPANTS
    d3.select('.total-participants')
      .text(this.total)
    
    // PARTICIPANTS GENDER
    var genderClasses = ['.ratio-participants-m', '.ratio-participants-w'];
    
    genderClasses.forEach(function(className, i) {
      d3.select(className)
        .text(format(this.genderRatio[i]));
    }.bind(this));
    
    // SURPLUS, EQ AND DEFICIT
    var budgetClasses = ['.ratio-responses-sp', '.ratio-responses-eq', '.ratio-responses-df'];
    
    budgetClasses.forEach(function(className, i){
      d3.select(className)
        .text(format(this.eqRatio[i]));
    }.bind(this));
    
    // AVG AGE
    d3.select('.avg-participants')
      .text(accounting.formatNumber(this.avgAge, 0));
      
    // PLACES LIST
    var placeList = d3.select('.location-participants')
      .append('ol')
      .selectAll('li')
      .data(this.places)
      .enter();

    placeList
      .append('li')
      .text(function(d) { return d.location + ': ' + format(d.responses); });
      
    // TABLE
    var columns = [
      { head: 'Preguntas', cl: 'title', html: function(d) { return d.key; } },
      { head: 'Reducir', cl: 'center', html: function(d) { return typeof d.values[0] !== 'undefined' ? format(d.values[0].value) : '—' } },
      { head: 'Mantener', cl: 'center', html: function(d) { return typeof d.values[1] !== 'undefined' ? format(d.values[1].value) : '—' } },
      { head: 'Aumentar', cl: 'center', html: function(d) { return typeof d.values[2] !== 'undefined' ? format(d.values[2].value) : '—' } },
    ];
    
    var table = d3.select('#table_report')
      .append('table');
      
    table.append('thead')
      .append('tr')
      .selectAll('th')
      .data(columns)
      .enter()
      .append('th')
      .attr('class', function(d) { return d.cl; })
      .text(function(d) { return d.head; });
      
    table.append('tbody')
      .selectAll('tr')
      .data(this.table)
      .enter()
      .append('tr')
      .selectAll('td')
      .data(function(row, i) {
        return columns.map(function(c) {
          var cell = {};

          d3.keys(c).forEach(function(k) {
            cell[k] = typeof c[k] == 'function' ? c[k](row,i) : c[k];
          });
          return cell;
        });
      })
      .enter()
      .append('td')
      .html(function(d) { return d.html; })
      .attr('class', function(d) { return d.cl; });
    
  }
});
