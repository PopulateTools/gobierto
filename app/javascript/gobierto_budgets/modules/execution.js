import { GOBIERTO_BUDGETS } from '../../lib/events';
import { VisLinesExecution } from '../../lib/visualizations';

$(document).on('turbolinks:load', function() {

  function updateExpenses(expensesKind) {
    $('.expenses_execution').html('');

    $('.expenses_switcher').removeClass('active');
    $('.expenses_switcher[data-toggle="' + expensesKind + '"]').addClass('active');

    // Reset every button
    $('.sort-G').removeClass('active');
    $('.value-switcher-G').removeClass('active');

    $(".sort-G[data-toggle='highest']").addClass('active');
    $(".value-switcher-G[data-toggle='pct_executed']").addClass('active');

    // Render the new category
    var vis_expenses_execution = new VisLinesExecution('.expenses_execution', 'G', expensesKind)
    vis_expenses_execution.render();

    // Avoid changing the chart meanwhile previous is loading
    $('.expenses_switcher').not('.active').prop('disabled', true);
    window.addEventListener(GOBIERTO_BUDGETS.LOADED, function () {
      $('.expenses_switcher').not('.active').prop('disabled', false);
    })

    window.addEventListener("resize", _.debounce(function () {
      vis_expenses_execution.setScales();
      vis_expenses_execution.updateRender();
    }, 250));

    $('.expenses_execution .tooltiped').tipsy({
      gravity: 's',
      trigger: 'hover',
      html: true
    });
  }

  function updateIncome(incomeKind) {
    $('.income_execution').html('');

    $('.income_switcher').removeClass('active');
    $('.income_switcher[data-toggle="' + incomeKind + '"]').addClass('active');

    // Reset every button
    $('.sort-I').removeClass('active');
    $('.value-switcher-I').removeClass('active');

    $(".sort-I[data-toggle='highest']").addClass('active');
    $(".value-switcher-I[data-toggle='pct_executed']").addClass('active');

    // Render the new category
    var vis_expenses_execution = new VisLinesExecution('.income_execution', 'I', incomeKind)
    vis_expenses_execution.render();

    // Avoid changing the chart meanwhile previous is loading
    $('.income_switcher').not('.active').prop('disabled', true);
    window.addEventListener(GOBIERTO_BUDGETS.LOADED, function () {
      $('.income_switcher').not('.active').prop('disabled', false);
    })

    window.addEventListener("resize", _.debounce(function () {
      vis_expenses_execution.setScales();
      vis_expenses_execution.updateRender();
    }, 250));

    $('.income_execution .tooltiped').tipsy({
      gravity: 's',
      trigger: 'hover',
      html: true
    });
  }

  if ($('body.budgets_execution_index').length) {

    var validValues = ['economic', 'functional', 'custom'];
    if (window.location.hash === "") {
      var expensesKind = $('.expenses_switcher').data('toggle');
      var incomeKind = $('.income_switcher').data('toggle');
      window.location.hash = "#" + expensesKind + "," + incomeKind;
    }

    if (validValues.indexOf(expensesKind) === -1) expensesKind = validValues[0];
    if (validValues.indexOf(incomeKind) === -1) incomeKind = validValues[0];

    $('.execution_vs_budget_table tr:nth-of-type(n+6)').hide()

    $('.execution_vs_budget_table + .more').on('click', function(e) {
      e.preventDefault();
      $(this).prev('.execution_vs_budget_table').find('tr:nth-of-type(n+6)').toggle();
      if ($(this).text() == $(this).data('more-literal'))
        $(this).text($(this).data('less-literal'));
      else
        $(this).text($(this).data('more-literal'));
    })

    if ($('.expenses_execution').length) {
      updateExpenses(expensesKind);

      $('.expenses_switcher').on('click', function (e) {
        expensesKind = $(e.target).attr('data-toggle');
        var newHash = '#' + [expensesKind, incomeKind].join(',');
        history.pushState({ 'expense': expensesKind, 'income': incomeKind }, { kind: 'expense', hash: newHash }, newHash);
        updateExpenses(expensesKind);
      });
    }

    if ($('.income_execution').length) {
      updateIncome(incomeKind);

      $('.income_switcher').on('click', function (e) {
        incomeKind = $(e.target).attr('data-toggle');
        var newHash = '#' + [expensesKind, incomeKind].join(',');
        history.pushState({ 'expense': expensesKind, 'income': incomeKind }, { kind: 'income', hash: newHash }, newHash);
        updateIncome(incomeKind);
      });
    }

    window.onpopstate = function(event) {
      if (event.state !== null && event.state.expense !== undefined) {
        if (expensesKind !== event.state.expense) {
          expensesKind = event.state.expense;
          updateExpenses(expensesKind);
        }
        if (incomeKind !== event.state.income) {
          incomeKind = event.state.income;
          updateIncome(incomeKind);
        }
      }
    }
  }
});
