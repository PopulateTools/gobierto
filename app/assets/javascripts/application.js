//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require i18n/translations
//= require jquery.magnific-popup.min
//= require sticky-kit.min
//= require jquery-ui
//= require html5sortable
//= require tipsy
//= require mustache.min
//= require velocity.min
//= require velocity.ui.min
//= require lodash.min.js
//= require d3.min
//= require d3-legend.min
//= require d3-locale-es
//= require d3-distance-limited-voronoi
//= require accounting.min
//= require jquery.autocomplete
//= require klass
//= require slick.min
//= require air-datepicker/datepicker.min
//= require air-datepicker/i18n/datepicker.es
//= require air-datepicker/i18n/datepicker.en
//= require_directory ./settings/

//= require module-admin
//= require module-sessions
//= require module-site_header

//= require flight-for-rails
//= require components/shareContent

// Global util functions
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

  // Include here common callbacks and behaviours

  // Tabs navigation
  $('[data-tab-target]').on('click', function(e){
    e.preventDefault();
    var target = $(this).data('tab-target');
    var scope = $('[data-tab-scope]').length ? $(this).closest('[data-tab-scope]') : $('body');

    scope.find('[data-tab-target]').parent().removeClass('active');
    scope.find('[data-tab-target="' + target + '"]').parent().addClass('active');
    scope.find('[data-tab]').removeClass('active');
    scope.find('[data-tab="' + target + '"]').addClass('active');
  });

  // Modal windows
  $('.open_modal').magnificPopup({
    type: 'inline',
    removalDelay: 300,
    mainClass: 'mfp-fade'
  });

  $('.open_remote_modal').magnificPopup({
    type: 'ajax',
    removalDelay: 300,
    mainClass: 'mfp-fade'
  });


  $('.close_modal').click(function(e) {
    $.magnificPopup.close();
  });

  // TODO: move to gobierto budget consultations
  $('.carousel').slick({
    dots: true,
    arrows: false,
    slidesToShow: 1,
    adaptiveHeight: true
  });

  $('.slick_next').click(function(e) {
    $('.carousel').slick('slickNext');
  });
  // End TODO

});
