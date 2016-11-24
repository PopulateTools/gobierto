//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require jquery.magnific-popup.min
//= require ./vendor/jquery-ui
//= require ./vendor/sticky-kit.min
//= require module-admin
//= require ./app/init
//= require_tree ./app

$(document).on('turbolinks:load', function() {

  // Tabs navigation
  $('[data-tab-target]').on('click', function(e){
    e.preventDefault();
    var target = $(this).data('tab-target');
    $('[data-tab-target]').parent().removeClass('active');
    $('[data-tab-target="' + target + '"]').parent().addClass('active');

    $('[data-tab]').removeClass('active');
    $('[data-tab="' + target + '"]').addClass('active');
  });

  // Modals
  $('.open_modal').magnificPopup({
    type: 'inline',
    removalDelay: 300,
    mainClass: 'mfp-fade'
  });

  $('.close_modal').click(function(e) {
    $.magnificPopup.close();
  });

});
