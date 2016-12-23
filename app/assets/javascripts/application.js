//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require i18n/translations
//= require jquery.magnific-popup.min
//= require sticky-kit.min
//= require tipsy
//= require mustache.min
//= require velocity.min
//= require velocity.ui.min
//= require d3.v3.min
//= require d3-legend.min
//= require accounting.min
//= require accounting_settings
//= require jquery.autocomplete
//= require autocomplete_settings
//= require klass
//= require slick.min
//= require air-datepicker/datepicker.min
//= require air-datepicker/i18n/datepicker.es

//= require vis_treemap
//= require vis_lineas_tabla
//= require vis_evo_line
//= require vis_age_distribution
//= require execution
//= require indicators
//= require module-admin
//= require module-consultations
//= require module-sessions
//= require flight-for-rails
//= require_directory ./components/

function rebindAll() {
  $('.tipsit').tipsy({fade: true, gravity: 's', html: true});
  $('.tipsit-n').tipsy({fade: true, gravity: 'n', html: true});
  $('.tipsit-w').tipsy({fade: true, gravity: 'w', html: true});
  $('.tipsit-e').tipsy({fade: true, gravity: 'e', html: true});
  $('.tipsit-treemap').tipsy({fade: true, gravity: $.fn.tipsy.autoNS, html: true});
}

function isDesktop(){
  return $(window).width() > 740;
}

$(document).on('turbolinks:load', function() {

  if(isDesktop()) {
    rebindAll();
  } else {
    $('.open_line_browser').hide();
  }

  // check if this is being used on top of the next
  // $('.tabs li a').click(function(e) {
  //   e.preventDefault();
  //   $(this).parent().parent().find('li').removeClass('active');
  //   $(this).parent().addClass('active');
  //   var tab = $(this).data("tab-target");
  //   $('.tab_content').hide();
  //   $('.tab_content[data-tab="'+tab+'"]').show();
  // });

  // Tabs navigation
  $('[data-tab-target]').on('click', function(e){
    e.preventDefault();
    var target = $(this).data('tab-target');
    $('[data-tab-target]').parent().removeClass('active');
    $('[data-tab-target="' + target + '"]').parent().addClass('active');

    $('[data-tab]').removeClass('active');
    $('[data-tab="' + target + '"]').addClass('active');
  });

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
    $('.line_browser').velocity("fadeIn", { duration: 50 });
  }, function(e) {
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

  $('.open_modal').magnificPopup({
    type: 'inline',
    removalDelay: 300,
    mainClass: 'mfp-fade'
  });

  $('.close_modal').click(function(e) {
    $.magnificPopup.close();
  });

  var $autocomplete = $('[data-autocomplete]');

  var searchOptions = {
    serviceUrl: $autocomplete.data('autocomplete'),
    onSelect: function(suggestion) {
      Turbolinks.visit(suggestion.data.url);
    },
    groupBy: 'category'
  };

  $autocomplete.autocomplete($.extend({}, AUTOCOMPLETE_DEFAULTS, searchOptions));

  $('.carousel').slick({
    dots: true,
    arrows: false,
    slidesToShow: 1,
    adaptiveHeight: true
  });

  $('.slick_next').click(function(e) {
    $('.carousel').slick('slickNext');
  });

  $('.air-datepicker').datepicker({
    language: 'es'
  });

  if($('#expense-treemap').length > 0){
    window.expenseTreemap = new TreemapVis('#expense-treemap', 'big', true);
    window.expenseTreemap.render($('#expense-treemap').data('functional-url'));
  }

});
