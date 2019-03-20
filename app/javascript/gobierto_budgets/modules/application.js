import { isDesktop, AUTOCOMPLETE_DEFAULTS } from 'lib/shared'
import Turbolinks from 'turbolinks'
import 'tipsy-1a'
import 'devbridge-autocomplete'
import 'sticky-kit/dist/sticky-kit.js'
import { VisTreemap, VisSlider, VisBubbles, VisBubbleLegend } from 'lib/visualizations'
import { getBudgetLevelData } from './classes/getBudgetLevelData.js'
// flight components
import './components/budgetLineBreadcrumb.js'
import './components/featuredBudgetLine.js'
import './components/visLine.js'

$(document).on('turbolinks:load ajax:complete ajaxSuccess', function() {
  if($('#expense-treemap').length && !$('#expense-treemap .treemap_node').length){
    let expenseTreemap = new VisTreemap('#expense-treemap', 'big', true);
    expenseTreemap.render($('#expense-treemap').data('functional-url'));

    window.addEventListener("resize", _.debounce(function () {
      expenseTreemap.render($('#expense-treemap').data('functional-url'));
    }, 250));
  }

  if($('#treemap').length && !$('#treemap .treemap_node').length){
    let expenseTreemap = new VisTreemap('#treemap', 'big', true);
    expenseTreemap.render($('#treemap').data('url'));

    window.addEventListener("resize", _.debounce(function () {
      expenseTreemap.render($('#treemap').data('url'));
    }, 250));
  }
})

$(document).on('turbolinks:load', function() {

  if(!isDesktop()) {
    $('.open_line_browser').hide();
  }

  if($('.vis-bubbles-expense').length && $('.vis-bubbles-income').length && !$('.vis-bubbles-expense svg').length && !$('.vis-bubbles-income svg').length) {
    var getBubbleData = new getBudgetLevelData();

    getBubbleData.getData(function() {
      new VisSlider('.timeline', window.budgetLevels);

      var visBubblesExpense = new VisBubbles('.vis-bubbles-expense', 'expense', window.budgetLevels);
      visBubblesExpense.render();

      var visBubblesIncome = new VisBubbles('.vis-bubbles-income', 'income', window.budgetLevels);
      visBubblesIncome.render();

      window.addEventListener("resize", _.debounce(function () {
        new VisSlider('.timeline', window.budgetLevels);

        visBubblesExpense.resize();
        visBubblesIncome.resize();

        if (window.innerWidth >= 1024) {
          new VisBubbleLegend('.bubble_legend');
        } else {
          $('.bubble_legend svg').remove();
        }
      }, 250));

      $(document).on('visSlider:yearChanged', function(e, year) {
        visBubblesIncome.update(year);
        visBubblesExpense.update(year);
      });
    });

    if (window.innerWidth >= 1024) {
      new VisBubbleLegend('.bubble_legend');
    }
  }

  var $autocomplete = $('[data-autocomplete]');

  var searchOptions = {
    serviceUrl: $autocomplete.data('autocomplete'),
    onSelect: function(suggestion) {
      Turbolinks.visit(suggestion.data.url);
    },
    groupBy: 'category'
  };

  $autocomplete.devbridgeAutocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $(".stick_ip").stick_in_parent()
    .on("sticky_kit:stick", function() {
      if($('.bread_links span').length)
        return;
      var title = $('h1').text();
      var breadLinksHtml = $('.bread_links').html();
      $('.bread_links').html(breadLinksHtml + ' <span>' + title + '</span>');
    })
    .on("sticky_kit:unstick", function() {
      var sep = ' » ';
      var breadLinksHtml = $('.bread_links').html();
      var arr = breadLinksHtml.split(sep);
      arr.pop();
      $('.bread_links').html(arr.join(sep) + sep);
    });

  $('.bread_hover').hover(function() {
    $('.bread_links a').attr('aria-expanded', true);
    $('.line_browser').velocity("fadeIn", { duration: 50 });
  }, function() {
    $('.bread_links a').attr('aria-expanded', false);
    $('.line_browser').velocity("fadeOut", { duration: 50 });
  });

  $('.open_line_browser').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    $('.line_browser').velocity("fadeIn", { duration: 250 });
  });

  $('.close_line_browser').click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    $('.line_browser').velocity("fadeOut", { duration: 150 });
  });

  $(window).click(function(){
    $('.line_browser').velocity("fadeOut", { duration: 150 });
  });

  $('.tooltiped-budget-lines').tipsy({
    gravity: 'se',
    trigger: 'manual',
    html: true,
    className: 'tipsy-lines'
  });

  $('.tooltiped-budget-lines').on('click', function() {
    $(this).tipsy("show");
  })

  $('.tooltiped').tipsy({
    gravity: 's',
    trigger: 'hover',
    html: true
  });
});
