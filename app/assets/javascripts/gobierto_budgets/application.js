//= require ./execution
//= require_directory ./components/
//= require_directory ./visualizations/

$(document).on('turbolinks:load', function() {

  if(isDesktop()) {
    rebindAll();
  } else {
    $('.open_line_browser').hide();
  }

  if($('#expense-treemap').length && !$('#expense-treemap svg').length){
    window.expenseTreemap = new TreemapVis('#expense-treemap', 'big', true);
    window.expenseTreemap.render($('#expense-treemap').data('functional-url'));
  }

  var $autocomplete = $('[data-autocomplete]');

  var searchOptions = {
    serviceUrl: $autocomplete.data('autocomplete'),
    onSelect: function(suggestion) {
      Turbolinks.visit(suggestion.data.url);
    },
    groupBy: 'category'
  };

  $autocomplete.autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $(".stick_ip").stick_in_parent()
    .on("sticky_kit:stick", function(e) {
      if($('.bread_links span').length)
        return;
      var title = $('h1').text();
      var breadLinksHtml = $('.bread_links').html();
      $('.bread_links').html(breadLinksHtml + ' <span>' + title + '</span>');
    })
    .on("sticky_kit:unstick", function(e) {
      var sep = ' » ';
      var title = $('h1').text();
      var breadLinksHtml = $('.bread_links').html();
      var arr = breadLinksHtml.split(sep);
      arr.pop();
      $('.bread_links').html(arr.join(sep) + sep);
    });

  $('.bread_hover').hover(function(e) {
    $('.bread_links a').attr('aria-expanded', true);
    $('.line_browser').velocity("fadeIn", { duration: 50 });
  }, function(e) {
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


  $('#executed-tooltip').tipsy({gravity: 's', trigger: 'hover' });
});
