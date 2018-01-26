//
// NOTE: THIS CONTROLLER LOADS D3.V3 TO ALLOW DC RUN
//
this.GobiertoBudgets.InvoicesController = (function() {

  function InvoicesController() {}

  InvoicesController.prototype.show = function(options) {

    $('#invoices-filters button').on('click', function (e) {
      var filter = $(e.target).attr('data-toggle');

      // Reset all buttons
      $('.sort-G').removeClass('active');

      $(".sort-G[data-toggle=" + filter + "]").addClass('active');

      getData(filter);
    });

    getData('12m');
  };

  // Global variables
  var data, ndx, _r;

  function getData(filter) {
    var dateRange;
    if (filter === '12m'){
      dateRange = moment().subtract(1, 'year').format('YYYYMMDD') + '-' + moment().format('YYYYMMDD');
    } else {
      var d1 = new Date(filter, 0, 1);
      var d2 = new Date(filter, 11, 31);
      dateRange = moment(d1).format('YYYYMMDD') + '-' + moment(d2).format('YYYYMMDD');
    }
    var municipalityId = window.populateData.municipalityId;
    var url = window.populateData.endpoint + '/datasets/ds-facturas-municipio.csv?filter_by_location_id='+municipalityId+'&date_date_range='+dateRange+'&sort_asc_by=date';
    d3.csv(url)
      .header('authorization', 'Bearer ' + window.populateData.token)
      .get(function(error, csv) {
        if (error) throw error;

        data = _.filter(csv, _callback(filter));

        _r = {
          domain: [501, 1001, 5001, 10001, 15001],
          range: [0, 1, 2, 3, 4, 5]
        };
        var rangeFormat = d3.scale.threshold().domain(_r.domain).range(_r.range);

        // pre-calculate for better performance
        data.forEach(function(d) {
          d.dd = new Date(d.date);
          d.month = moment(d.dd).endOf('month')._d;
          d.range = rangeFormat(+d.value);
          d.paid = (d.paid == 'true');
          d.value = Number(d.value);
          d.freelance = (d.freelance == 'true');
        });

        // See the [crossfilter API](https://github.com/square/crossfilter/wiki/API-Reference) for reference.
        ndx = crossfilter(data);

        _boxesCalculations();

        // BARS CHART - BY DATE
        _renderByMonthsChart();

        // ROW CHART - MAIN PROVIDERS
        _renderMainProvidersChart();

        // ROW CHART - BY AMOUNT
        _renderByAmountsChart();

        // TABLE FILTER - FULL PROVIDERS
        _renderTableFilter();
    });
  }

  function _callback(f) {
    var cb = function () {};

    // Return the filter callback function based on filter selected
    switch (f) {
      case '12m':
        cb = function (o) {
          return moment(new Date(o.date)) > moment().subtract(12, 'months')
        }
        break;
      default: // Filter is the year itself
        cb = function (o) {
          return moment(new Date(o.date)).year() === Number(f)
        }
    }

    return cb;
  }

  function _boxesCalculations() {

    // Totals box
    var totalAmount = _.sumBy(data, 'value');

    document.getElementById("numberOfInvoices").innerText = data.length.toLocaleString();
    document.getElementById("totalAmount").innerText = _abbrevLargeCurrency(totalAmount);

    var _cc = _.countBy(_.uniqBy(data, 'provider_name'), 'freelance');
    $('#providerType .number:first').text((_cc.true || 0).toLocaleString());
    $('#providerType .number:last').text((_cc.false || 0).toLocaleString());

    var _n = _.countBy(data, 'freelance');
    $('#providerType .percent:first').text((_n.true/data.length || 0).toLocaleString(I18n.locale, {
      style: 'percent'
    }));
    $('#providerType .percent:last').text((_n.false/data.length || 0).toLocaleString(I18n.locale, {
      style: 'percent'
    }));

    // Math results box
    function median(values) {
      values.sort(function(a, b) {
        return a - b;
      });
      var half = Math.floor(values.length / 2);

      if (values.length % 2)
        return values[half];
      else
        return (values[half - 1] + values[half]) / 2.0;
    }

    var amount = _.isEmpty(_.map(data, 'value').map(Number)) ? [0] : _.map(data, 'value').map(Number);

    document.getElementById("meanBudget").innerText = _.mean(amount).toLocaleString(I18n.locale, {
      style: 'currency',
      currency: 'EUR'
    });
    document.getElementById("medianBudget").innerText = median(amount).toLocaleString(I18n.locale, {
      style: 'currency',
      currency: 'EUR'
    });

    // Text info calculations
    function percentileAgg(arr, p) {
      if (arr.length === 0) return 0;

      arr.sort(function(a, b) {
        return a - b;
      }).reverse();

      var percentile = _.sum(arr) * p;
      var accumulate = 0;
      var i = 0;

      while (accumulate < percentile) {
        accumulate += +arr[i]
        i++;
      }

      return i / arr.length || 0;
    }

    var lt1000 = _.filter(amount, o => o <= 1000).length / data.length || 0; // Filter those amounts less than 1000
    var lgProvider = _.max(_.map(_.groupBy(data, 'provider_name'), group => _.sumBy(group, 'value'))) / totalAmount || 0; // Max amount group by provider amount

    document.getElementById("lessThan1000").innerText = lt1000.toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("largestProvider").innerText = lgProvider.toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("percentile50").innerText = percentileAgg(amount, 0.5).toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("percentile10").innerText = percentileAgg(amount, 0.1).toLocaleString(I18n.locale, {
      style: 'percent'
    });

  }

  function _renderByMonthsChart() {
    // Declaration
    var bars = dc.barChart("#bars", "group");

    // Dimensions
    var months = ndx.dimension(function(d) {
        return d.month;
      }),
      budgetMonthly = months.group().reduceSum(function(d) {
        return +d.value;
      });

    bars
      .width(bars.root().node().parentNode.getBoundingClientRect().width) // NOTE: webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .dimension(months)
      .group(budgetMonthly)
      .x(d3.scale.ordinal())
      .xUnits(dc.units.ordinal)
      .round(d3.time.month.round)
      .elasticX(true)
      .elasticY(true)
      .alwaysUseRounding(true)
      .renderHorizontalGridLines(true)
      .barPadding(0.45)
      .title(function(d) { return _abbrevLargeCurrency(d.value, { minimumFractionDigits: 0 }); })
      .on('renderlet', function(chart){
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart.selectAll('rect').attr("rx", 4).attr("ry", 4);
      });

    // Customize
    bars.xAxis().tickFormat(function(d) {
      var _mf = d3.locale(eval(I18n.locale)).timeFormat('%b');
      return _mf(d).toUpperCase();
    });
    bars.yAxis().ticks(5);
    bars.yAxis().tickFormat(
      function(v) {
        return _abbrevLargeCurrency(v, {
          minimumFractionDigits: 0
        })
      });
    bars.margins().left = 80;
    bars.margins().right = 0;

    // Render
    bars.render();
  }

  function _renderMainProvidersChart() {
    // Declaration
    var hbars1 = dc.rowChart("#hbars1", "group");

    // Dimensions
    var providers = ndx.dimension(function(d) {
        return d.provider_name
      }),
      providerByAmount = providers.group().reduceSum(function(d) {
        return +d.value;
      });

    // Styling
    var _count = 10,
      _gap = 10,
      _barHeight = 15,
      _labelOffset = 195;

    hbars1
      .width(hbars1.root().node().parentNode.getBoundingClientRect().width) // NOTE: webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .height(hbars1.margins().top + hbars1.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // NOTE: Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .cap(_count).othersGrouper(null) // NOTE: Show only a couple of results, and hide Others groups
      .x(d3.scale.ordinal())
      .dimension(providers)
      .group(providerByAmount)
      .gap(_gap)
      .labelOffsetX(-_labelOffset)
      .label(function (d) {
        return((d.key.length > 24) ? d.key.slice(0, 24) + "..." : d.key);
      })
      .title(function(d) { return d.key + " - " + _abbrevLargeCurrency(d.value, { minimumFractionDigits: 0 }); })
      .elasticX(true)
      .on('pretransition', function(chart){
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart.selectAll('rect').attr("rx", 4).attr("ry", 4);

        chart.select('g.axis')
          .attr("transform", "translate(0,0)")
          .append('text')
          .text(I18n.t('gobierto_budgets.invoices.show.invoiced'))
          .attr("x", -9 * 3)
          .attr("y", -9) // Default
          .attr("class", "axis-title")
          .attr("text-anchor","end");

        chart.selectAll('g.axis line.grid-line').attr("y2", function() {
          return Math.abs(+d3.select(this).attr("y2")) + (chart.margins().top / 2)
        });

        $('#providers-number').html(providers.group().all().length - _count);
      });

    // Customize
    hbars1.xAxis().tickFormat(function(v) {
      return _abbrevLargeCurrency(v, {
        minimumFractionDigits: 0
      });
    });
    hbars1.xAxis().ticks(3).orient('top');
    hbars1.margins().top = 20;
    hbars1.margins().left = _labelOffset + 5;
    hbars1.margins().right = 10;

    // Render
    hbars1.render();
  }

  function _renderByAmountsChart() {
    // Declaration
    var hbars2 = dc.rowChart("#hbars2", "group");

    // Dimensions
    var amounts = ndx.dimension(function(d) {
        return d.range
      }),
      amountByInvoices = amounts.group().reduceCount();

    // Styling
    var _count = amountByInvoices.size(),
      _gap = 10,
      _barHeight = 18,
      _labelOffset = 195;

    hbars2
      .width(hbars2.root().node().parentNode.getBoundingClientRect().width) // NOTE: webkit doesn't recalculate dynamic width. it has to be set by parentNode
      .height(hbars2.margins().top + hbars2.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // NOTE: Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .x(d3.scale.threshold())
      .dimension(amounts)
      .group(amountByInvoices)
      .ordering(function(d) {
        return d.key
      })
      .labelOffsetX(-_labelOffset)
      .gap(_gap)
      .elasticX(true)
      .title(function(d) { return d.value })
      .label(function(d) {
        // Helper
        function intervalFormat(n) {
          var _s = Number(_r.domain[d.key - 1]) || 1;

          // Last value is not a range
          if (d.key === _r.domain.length) {
            return I18n.t('gobierto_budgets.invoices.show.more') + " " + (_s - 1).toLocaleString(I18n.locale, {
              style: 'currency',
              currency: 'EUR',
              minimumFractionDigits: 0
            })
          }

          var _l = Number(n - 1);

          return [_s, _l].map(n => n.toLocaleString(I18n.locale, {
            style: 'currency',
            currency: 'EUR',
            minimumFractionDigits: 0
          })).join((d.key === 0) ? '\t\t\t\t\t' : (d.key > 3) ? '\t\t\t' : '\t\t\t\t')
        }

        return intervalFormat(Number(_r.domain[d.key]))
      })
      .on('pretransition', function(chart){
        // Apply rounded corners AFTER render, otherwise they don't exist
        chart.selectAll('rect').attr("rx", 4).attr("ry", 4);

        chart.select('g.axis')
          .attr("transform", "translate(0,0)")
          .append('text')
          .html(function() {
            // Helper
            function titleFormat(str) {
              var tabs = "&ensp;&emsp;";
              return str.replace(" ", tabs.repeat(6) + "&nbsp;").replace(" ", tabs.repeat(3) + "&nbsp;")
            }

            return titleFormat(I18n.t('gobierto_budgets.invoices.show.fromto'));
          })
          .attr("x", -_labelOffset)
          .attr("y", -9) // Default
          .attr("class", "axis-title");

        chart.selectAll('g.axis line.grid-line').attr("y2", function() {
          return Math.abs(+d3.select(this).attr("y2")) + (chart.margins().top / 2)
        });
      });

    // Customize
    hbars2.xAxis().ticks(5).orient('top');
    hbars2.xAxis().tickFormat(
      function(tick, pos) {
        if (pos === 0) return null
        return tick
      });
    hbars2.margins().top = 20;
    hbars2.margins().left = _labelOffset + 5;
    hbars2.margins().right = 0;

    // Render
    hbars2.render();
  }

  function _renderTableFilter() {

    $("#providers-table").jsGrid({
      width: "100%",
      height: "auto",
      filtering: true,
      sorting: true,
      autoload: true,
      paging: true,
      pagerFormat: I18n.t('gobierto_budgets.invoices.show.table.pager.format', { tpl: '{first} {prev} {pages} {next} {last} &nbsp;&nbsp; {pageIndex}', tpl2: '{pageCount}' }),
      pageNextText: I18n.t('gobierto_budgets.invoices.show.table.pager.next'),
      pagePrevText: I18n.t('gobierto_budgets.invoices.show.table.pager.prev'),
      pageFirstText: I18n.t('gobierto_budgets.invoices.show.table.pager.first'),
      pageLastText: I18n.t('gobierto_budgets.invoices.show.table.pager.last'),
      controller: {
        loadData: function(filter) {
          return $.grep(data, function(row) {
            return (!filter.provider_name.toLowerCase() || row.provider_name.toLowerCase().indexOf(filter.provider_name.toLowerCase()) > -1) &&
              (!filter.provider_id.toLowerCase().toLowerCase() || row.provider_id.toLowerCase().indexOf(filter.provider_id.toLowerCase()) > -1) &&
              (!filter.date || row.date.indexOf(filter.date) > -1) &&
              (filter.paid === undefined || row.paid === filter.paid) &&
              (!filter.value || row.value === filter.value) &&
              (!filter.subject.toLowerCase() || row.subject.toLowerCase().indexOf(filter.subject.toLowerCase()) > -1);
          });
        },
      },
      fields: [{
          name: "provider_id",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.provider_id'),
          type: "text",
          autosearch: true,
          align: "center",
          width: 30
        },
        {
          name: "provider_name",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.provider_name'),
          type: "text",
          autosearch: true,
          width: 50
        },
        {
          name: "date",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.date'),
          type: "text",
          align: "center",
          width: 30,
          itemTemplate: function(value, item) {
            return new Date(value).toLocaleDateString(I18n.locale)
          }
        },
        {
          name: "paid",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.paid'),
          type: "checkbox",
          align: "center",
          width: 20
        },
        {
          name: "value",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.value'),
          type: "number",
          width: 20,
          itemTemplate: function(value, item) {
            return value.toLocaleString(I18n.locale, {
              style: 'currency',
              currency: 'EUR',
              minimumFractionDigits: 0
            })
          }
        },
        {
          name: "subject",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.subject'),
          type: "text",
          autosearch: true
        }
      ]
    });
  }

  function _abbrevLargeCurrency(num, props = {}, currency = 'EUR') {
    var _obj = {
      style: 'currency',
      currency: currency
    };

    return (num > 1000000) ? num.toLocaleString(I18n.locale, _.extend(_obj, {
      maximumSignificantDigits: 3 //Math.log10(pow) / 2 + 1
    })).split('').reverse().join('').replace(/000000(.|,)/, 'M').split('').reverse().join('') : num.toLocaleString(I18n.locale, _.extend(_obj, props));
  }

  return InvoicesController;
})();

this.GobiertoBudgets.invoices_controller = new GobiertoBudgets.InvoicesController;
