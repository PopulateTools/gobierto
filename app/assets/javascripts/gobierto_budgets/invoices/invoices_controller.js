//
// NOTE: THIS CONTROLLER LOADS D3.V3 TO ALLOW DC RUN
//
this.GobiertoBudgets.InvoicesController = (function() {

  function InvoicesController() {}

  InvoicesController.prototype.show = function(options){

    var data = d3.csv.parse(d3.select('pre#data').text().trim());
    // d3.csv('budget_invoices-providers.mock.csv', function (data) {

    // Boxes calculations
    function median(values){
    	values.sort(function(a,b){
      	return a-b;
      });
      var half = Math.floor(values.length / 2);

      if (values.length % 2)
      	return values[half];
      else
      	return (values[half - 1] + values[half]) / 2.0;
    }

    document.getElementById("numberOfInvoices").innerText = data.length.toLocaleString();
    document.getElementById("meanBudget").innerText = _.mean(_.map(data, 'amount').map(Number)).toLocaleString(I18n.locale, { style: 'currency', currency: 'EUR' });
    document.getElementById("medianBudget").innerText = median(_.map(data, 'amount').map(Number)).toLocaleString(I18n.locale, { style: 'currency', currency: 'EUR' });

    var dateFormat = d3.time.format('%Y/%m/%d');
    var _r = {
      domain: [501, 1001, 5001, 10001, 15001],
      // range: [0, "501€ - 1000€", "1001€ - 5000€", "5001€ - 10000€", "10001€ - 15000€", "+15000€"]
      range: [0, 1, 2, 3, 4, 5]
    };
    var rangeFormat = d3.scale.threshold().domain(_r.domain).range(_r.range);
    // pre-calculate for better performance
    data.forEach(function (d) {
      d.dd = dateFormat.parse(d.date);
      d.month = d3.time.month(d.dd);
      d.range = rangeFormat(+d.amount);
      d.payed = (d.payed == 'true');
      d.amount = Number(d.amount);
    });

    // See the [crossfilter API](https://github.com/square/crossfilter/wiki/API-Reference) for reference.
    var ndx = crossfilter(data);

    /*
      BARS CHART - BY DATE
    */

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
      .barPadding(0.5);

    // Customize
    bars.xAxis().tickFormat(function(d) {
      var _mf = d3.locale(eval(I18n.locale)).timeFormat('%b');
      return _mf(d).toUpperCase();
    });
    bars.yAxis().ticks(5);
    bars.yAxis().tickFormat(
      function(v) {
        return v.toLocaleString(I18n.locale, { style: 'currency', currency: 'EUR', minimumFractionDigits: 0 });
      });
    bars.margins().left = 60;

    // Render
    bars.render();

    /*
      ROW CHART - MAIN PROVIDERS
    */

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
      _gap = 5, // DC default
      _barHeight = 20;

    hbars1
      .height(hbars1.margins().top + hbars1.margins().bottom + (_count * _barHeight) + ((_count + 1) * _gap)) // NOTE: Margins top/bottom + bars + gaps (space between)
      .fixedBarHeight(_barHeight)
      .cap(_count).othersGrouper(null) // NOTE: Show only a couple of results, and hide Others groups
      .x(d3.scale.ordinal())
      .dimension(providers)
      .group(providerByAmount)
      .labelOffsetX(-95)
      .elasticX(true);

    // Customize
    hbars1.xAxis().tickFormat(function (v) {
      return v.toLocaleString(I18n.locale, { style: 'currency', currency: 'EUR', minimumFractionDigits: 0 });
    });
    hbars1.xAxis().ticks(5);
    hbars1.margins().left = 100;

    // Render
    hbars1.render();

    /*
      ROW CHART - BY AMOUNT
    */

    // Declaration
    var hbars2 = dc.rowChart("#hbars2", "group");

    // Dimensions
    var amounts = ndx.dimension(function(d) {
        return d.range
      }),
      amountByInvoices = amounts.group().reduceCount();

    // Styling
    var _count = amountByInvoices.size(),
      _gap = 5, // DC default
      _barHeight = 20;

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
      .labelOffsetX(-100)
      .label(function(d) {
        // Helper
        function intervalFormat(n) {
          let _s = Number(_r.domain[d.key - 1]) || 1;
          let _l = Number(n - 1);
          return [_s,_l].map(n => n.toLocaleString(I18n.locale, { style: 'currency', currency: 'EUR', minimumFractionDigits: 0 })).join('\t') //TODO: No pinta el tabulador
        }

        return intervalFormat(Number(_r.domain[d.key]))})
      .elasticX(true);

    // Customize
    hbars2.xAxis().ticks(5);
    hbars2.margins().left = 100;

    // Render
    hbars2.render();

    /*
      TABLE FILTER - FULL PROVIDERS
    */

    $("#providers-table").jsGrid({
      width: "100%",
      height: "auto",
      filtering: true,
      sorting: true,
      autoload: true,
      paging: true,
      data: data,
      fields: [{
          name: "nif",
          type: "text",
          autosearch: true,
          align: "center",
          width: 30
        },
        {
          name: "name",
          type: "text",
          autosearch: true,
          width: 80
        },
        {
          name: "date",
          type: "text",
          align: "center",
          width: 30
        },
        {
          name: "payed",
          type: "checkbox",
          align: "center",
          width: 20
        },
        {
          name: "amount",
          type: "number",
          width: 30
        },
        {
          name: "concept",
          type: "text",
          autosearch: true
        }
      ]
    });

    // });
  };

  return InvoicesController;
})();

this.GobiertoBudgets.invoices_controller = new GobiertoBudgets.InvoicesController;
