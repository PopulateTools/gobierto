//
// NOTE: THIS CONTROLLER LOADS D3.V3 TO ALLOW DC RUN
//
this.GobiertoBudgets.InvoicesController = (function() {

  function InvoicesController() {}

  InvoicesController.prototype.show = function(options) {
    getData(options);
  };

  // Global variables
  var data, ndx, _r;

  function getData(f = '12m') {
    d3.csv('/data.csv', function(csv) {

      data = _.filter(csv, _callback(f));

      _r = {
        domain: [501, 1001, 5001, 10001, 15001],
        range: [0, 1, 2, 3, 4, 5]
      };
      var rangeFormat = d3.scale.threshold().domain(_r.domain).range(_r.range);
      var dateFormat = d3.time.format('%Y/%m/%d');

      // pre-calculate for better performance
      data.forEach(function(d) {
        d.dd = dateFormat.parse(d.date);
        d.month = d3.time.month(d.dd);
        d.range = rangeFormat(+d.amount);
        d.payed = (d.payed == 'true');
        d.amount = Number(d.amount);

        // TODO: Columna falsa para autónomos
        d.freelance = (Math.random() >= 0.25);
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
      case 'current':
        cb = function (o) {
          return moment(new Date(o.date)).year() === moment().year()
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
    // Boxes calculations
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

    document.getElementById("numberOfInvoices").innerText = data.length.toLocaleString();
    document.getElementById("meanBudget").innerText = _.mean(_.map(data, 'amount').map(Number)).toLocaleString(I18n.locale, {
      style: 'currency',
      currency: 'EUR'
    });
    document.getElementById("medianBudget").innerText = median(_.map(data, 'amount').map(Number)).toLocaleString(I18n.locale, {
      style: 'currency',
      currency: 'EUR'
    });

    var _n = _.countBy(data, 'freelance');
    $('#providerType .number:first').text(_n.true.toLocaleString());
    $('#providerType .number:last').text(_n.false.toLocaleString());
    $('#providerType .percent:first').text((_n.true/data.length).toLocaleString(I18n.locale, {
      style: 'percent'
    }));
    $('#providerType .percent:last').text((_n.false/data.length).toLocaleString(I18n.locale, {
      style: 'percent'
    }));
  }

  function _renderByMonthsChart() {
    // Declaration
    var bars = dc.barChart("#bars", "group");

    // Dimensions
    var months = ndx.dimension(function(d) {
        return d.month
      }),
      budgetMonthly = months.group().reduceSum(function(d) {
        return +d.amount;
      });

    bars
      .dimension(months)
      .group(budgetMonthly)
      .x(d3.scale.ordinal())
      .xUnits(dc.units.ordinal)
      .round(d3.time.month.round)
      .elasticX(true)
      .elasticY(true)
      .alwaysUseRounding(true)
      .renderHorizontalGridLines(true)
      .barPadding(0.45);

    // Customize
    bars.xAxis().tickFormat(function(d) {
      var _mf = d3.locale(eval(I18n.locale)).timeFormat('%b');
      return _mf(d).toUpperCase();
    });
    bars.yAxis().ticks(5);
    bars.yAxis().tickFormat(
      function(v) {
        return v.toLocaleString(I18n.locale, {
          style: 'currency',
          currency: 'EUR',
          minimumFractionDigits: 0
        });
      });
    bars.margins().left = 80;
    bars.margins().right = 0;

    // Render
    bars.render();

    // Apply rounded corners AFTER render, otherwise they don't exist
    bars.selectAll('rect').attr("rx", 4).attr("ry", 4);
  }

  function _renderMainProvidersChart() {
    // Declaration
    var hbars1 = dc.rowChart("#hbars1", "group");

    // Dimensions
    var providers = ndx.dimension(function(d) {
        return d.name
      }),
      providerByAmount = providers.group().reduceSum(function(d) {
        return +d.amount;
      });

    // Styling
    var _count = 10,
      _gap = 10, // DC default
      _barHeight = 15;

    hbars1
      .height(hbars1.margins().top + hbars1.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // NOTE: Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .cap(_count).othersGrouper(null) // NOTE: Show only a couple of results, and hide Others groups
      .x(d3.scale.ordinal())
      .dimension(providers)
      .group(providerByAmount)
      .gap(_gap)
      .labelOffsetX(-195)
      .elasticX(true);

    // Customize
    hbars1.xAxis().tickFormat(function(v) {
      return v.toLocaleString(I18n.locale, {
        style: 'currency',
        currency: 'EUR',
        minimumFractionDigits: 0
      });
    });
    hbars1.xAxis().ticks(3);
    hbars1.margins().left = 200;
    hbars1.margins().right = 10;

    // Render
    hbars1.render();

    // Apply rounded corners AFTER render, otherwise they don't exist
    hbars1.selectAll('rect').attr("rx", 4).attr("ry", 4);
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
      _gap = 10, // DC default
      _barHeight = 15;

    hbars2
      .height(hbars2.margins().top + hbars2.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // NOTE: Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .x(d3.scale.threshold())
      .dimension(amounts)
      .group(amountByInvoices)
      // .ordering(function(d) { return _r.range.indexOf(d.key) })
      .ordering(function(d) {
        return d.key
      })
      .labelOffsetX(-195)
      .gap(_gap)
      .label(function(d) {
        // Helper
        function intervalFormat(n) {
          let _s = Number(_r.domain[d.key - 1]) || 1;

          // Last value is not a range
          if (d.key === _r.domain.length) {
            return I18n.t('gobierto_budgets.invoices.show.more') + " " + (_s - 1).toLocaleString(I18n.locale, {
              style: 'currency',
              currency: 'EUR',
              minimumFractionDigits: 0
            })
          }

          let _l = Number(n - 1);

          return [_s, _l].map(n => n.toLocaleString(I18n.locale, {
            style: 'currency',
            currency: 'EUR',
            minimumFractionDigits: 0
          })).join((d.key === 0) ? '\t\t\t\t\t' : (d.key > 3) ? '\t\t\t' : '\t\t\t\t')
        }

        return intervalFormat(Number(_r.domain[d.key]))
      })
      .elasticX(true);

    // Customize
    hbars2.xAxis().ticks(5);
    hbars2.margins().left = 200;
    hbars2.margins().right = 0;

    // Render
    hbars2.render();

    // Apply rounded corners AFTER render, otherwise they don't exist
    hbars2.selectAll('rect').attr("rx", 4).attr("ry", 4);
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
            return (!filter.name.toLowerCase() || row.name.toLowerCase().indexOf(filter.name.toLowerCase()) > -1) &&
              (!filter.nif.toLowerCase().toLowerCase() || row.nif.toLowerCase().indexOf(filter.nif.toLowerCase()) > -1) &&
              (!filter.date || row.date.indexOf(filter.date) > -1) &&
              (filter.payed === undefined || row.payed === filter.payed) &&
              (!filter.amount || row.amount === filter.amount) &&
              (!filter.concept.toLowerCase() || row.concept.toLowerCase().indexOf(filter.concept.toLowerCase()) > -1);
          });
        },
      },
      fields: [{
          name: "nif",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.nif'),
          type: "text",
          autosearch: true,
          align: "center",
          width: 30
        },
        {
          name: "name",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.name'),
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
          name: "payed",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.payed'),
          type: "checkbox",
          align: "center",
          width: 20
        },
        {
          name: "amount",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.amount'),
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
          name: "concept",
          title: I18n.t('gobierto_budgets.invoices.show.table.fields.concept'),
          type: "text",
          autosearch: true
        }
      ]
    });
  }

  return InvoicesController;
})();

this.GobiertoBudgets.invoices_controller = new GobiertoBudgets.InvoicesController;
